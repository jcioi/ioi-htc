#!/usr/bin/env ruby
require 'pathname'
require 'json'
require 'tempfile'
require 'aws-sdk-s3'
require 'aws-sdk-sqs'

class Worker
  def initialize(queue_name: ENV.fetch('QUEUE_NAME'), workdir: '/var/lib/cms-import-statement-worker', logger:)
    @logger = logger
    @sqs = Aws::SQS::Client.new(logger: @logger)
    @s3 = Aws::S3::Client.new(logger: @logger)
    @queue_name = queue_name
    @workdir = Pathname(workdir)
  end

  attr_reader :sqs, :s3, :queue_name, :workdir, :logger

  def run
    loop do
      resp = sqs.receive_message(queue_url: queue_url, wait_time_seconds: 20)
      next sleep 10 if resp.messages.empty?
      resp.messages.each do |message|
        handle_message(JSON.parse(message.body))
        sqs.delete_message(queue_url: queue_url, receipt_handle: message.receipt_handle)
      end
    rescue => e
      logger.error { e }
      sleep 10
    end
  end


  private

  class Failure < StandardError; end

  def queue_url
    @queue_url ||= sqs.get_queue_url(queue_name: queue_name).queue_url
  end

  def handle_message(message)
    type = message.fetch('type')
    task_name = message.fetch('task_name')
    language_code = message.fetch('language_code')

    case type
    when 'statement_updated'
      handle_statement_updated(
        task_name: task_name,
        language_code: language_code,
        s3_bucket: message.fetch('s3_bucket'),
        s3_key: message.fetch('s3_key'),
      )
    when 'statement_deleted'
      # todo
    else
      raise Failure, "Unknown message type: #{type}"
    end
  end

  def handle_statement_updated(task_name:, language_code:, s3_bucket:, s3_key:)
    file = Tempfile.open(["#{task_name}-#{language_code}-", '.pdf'], workdir) do |file|
      s3.get_object(bucket: s3_bucket, key: s3_key, response_target: file)
      file
    end

    unless system('ioi-cms-venv', 'cmsAddStatement', '--overwrite', task_name, language_code, file.path)
      raise Failure, "cmsAddStatement: #$?"
    end
  end
end

$stdout.sync = true
Worker.new(logger: Logger.new($stdout)).run
