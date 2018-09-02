#!/usr/bin/env ruby
require 'aws-sdk-codepipeline'
require 'aws-sdk-s3'
require 'pathname'
require 'fileutils'
require 'logger'
require 'json'
require 'socket'

class Worker
  def initialize(codebuild, dir = '/var/lib/cms-import-task-worker')
    @codebuild = codebuild
    @dir = Pathname.new(dir)
    @jobs_dir = @dir.join('jobs').tap(&:mkpath)
    @finished_jobs_dir = @dir.join('finished_jobs').tap(&:mkpath)
    @artifacts_dir = @dir.join('artifacts').tap(&:mkpath)
    @work_dir = @dir.join('work').tap(&:mkpath)
  end

  attr_reader :codebuild, :dir, :jobs_dir, :finished_jobs_dir, :artifacts_dir, :work_dir

  def run
    loop do
      payload = codebuild.poll_for_jobs(
        action_type_id: {
          category: "Deploy",
          owner: "Custom",
          provider: "CmsImportTask",
          version: "5b6b53fc",
        },
        max_batch_size: 1,
        query_param: {
          "cluster" => ENV.fetch('CMS_CLUSTER'),
        },
      )
      payload.jobs.each do |job_data|
        Job.new(
          codebuild,
          job_data.to_h,
          job_path: jobs_dir.join(job_data.id),
          finished_job_path: finished_jobs_dir.join(job_data.id),
          artifact_dir: artifacts_dir.join(job_data.id).tap(&:mkpath),
          work_dir: work_dir.join(job_data.id).tap(&:mkpath),
        ).perform!
      end
      sleep 12 if payload.jobs.empty?
    end
  end

  class Job
    class Failure < StandardError; end

    def initialize(codebuild, data, job_path:, finished_job_path:, artifact_dir:, work_dir:)
      @codebuild = codebuild
      @data = data
      @job_path = job_path
      @finished_job_path = finished_job_path
      @artifact_dir = artifact_dir
      @work_dir = work_dir
      @task_dir = work_dir.join('task').tap(&:mkpath)
      execution_id # Generate
    end

    attr_reader :codebuild
    attr_reader :data, :finished_job_path, :job_path, :artifact_dir, :work_dir, :task_dir

    def perform!
      log "Performing job: #{id}"
      acknowledge!

      prepare_artifact!
      import!

      report_success!
      cleanup!
      log "All done: #{id}"
    rescue => e
      report_failure!(e)
    end

    def acknowledge!
      File.write job_path.to_s, "#{to_json}\n", perm: 0600
      codebuild.acknowledge_job({
        job_id: id, # required
        nonce: data.fetch(:nonce), # required
      })
      log "Acknowledged"
    end

    def prepare_artifact!
      log "Preparing artifact"
      raise Failure, "Artifact type must be S3" unless input_artifact.dig(:location, :type) == 'S3'

      s3 = Aws::S3::Client.new(region: ENV.fetch('AWS_REGION'), credentials: artifact_credentials, logger: Logger.new($stdout))
      File.open(artifact_path, 'w') do |io|
        bucket = input_artifact.fetch(:location).fetch(:s3_location).fetch(:bucket_name)
        key = input_artifact.fetch(:location).fetch(:s3_location).fetch(:object_key)
        log "fetching artifact from s3://#{bucket}/#{key}"
        s3.get_object(
          bucket: bucket,
          key: key,
          response_target: io,
        )
      end

      log "unzip #{artifact_path.to_s}"
      system("unzip", artifact_path.to_s, "-d", task_dir.to_s) or raise Failure, "unzip failed"
    end

    def import!
      Dir.chdir(task_dir.to_s) do
        log "importing #{task_dir.to_s} (ioi-cms-venv cmsImportTask -u -S .)"
        system("ioi-cms-venv", "cmsImportTask", "-u", "-S", ".", chdir: task_dir.to_s) or raise Failure, "CmsImportTask failed"
      end
    end

    def report_success!
      log "Reporting success"
      codebuild.put_job_success_result(
        job_id: id,
        execution_details: {
          external_execution_id: execution_id,
          percent_complete: 100,
          summary: "Done",
        },
      )
      File.rename(job_path.to_s, finished_job_path.to_s) if job_path.exist?
    end

    def report_failure!(e)
      log "Reporting failure"
      log e.full_message
      codebuild.put_job_failure_result({
        job_id: id,
        failure_details: {
          type: e.is_a?(Failure) ? "JobFailed" : "SystemUnavailable",
          message: "#{e.class}: #{e.message}",
          external_execution_id: execution_id,
        },
      })
    end

    def cleanup!
      log "cleaning up: #{work_dir}"
      FileUtils.remove_entry_secure work_dir.to_s
      log "cleaning up: #{artifact_dir}"
      FileUtils.remove_entry_secure artifact_dir.to_s
    end

    def input_artifact
      data.fetch(:data).fetch(:input_artifacts).fetch(0)
    end

    def artifact_path
      artifact_dir.join("input.zip")
    end

    def artifact_credentials
      @artifact_credentials ||= data[:data].fetch(:artifact_credentials).yield_self do |cred|
        Aws::Credentials.new(
          cred.fetch(:access_key_id),
          cred.fetch(:secret_access_key),
          cred.fetch(:session_token, nil),
        )
      end
    end

    def execution_id
      @execution_id ||= "#{Socket.gethostname}/#{$$}/#{Time.now.to_i.to_s(36)}"
    end

    def id
      data.fetch(:id)
    end

    def to_h
      data.to_h
    end

    def to_json
      to_h.to_json
    end

    private

    def log(msg)
      $stdout.puts "#{execution_id}(#{id}): #{msg}"
    end
  end
end


$stdout.sync = true
Worker.new(Aws::CodePipeline::Client.new(region: ENV.fetch('AWS_REGION'), logger: Logger.new($stdout))).run
