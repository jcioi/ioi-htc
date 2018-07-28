{
  ### "System-wide configuration",
  temp_dir: "/tmp",

  log_dir: "/var/log/cms",
  cache_dir: "/var/cache/cms",
  data_dir: "/var/lib/cms",
  run_dir: "/run/cms",

  # "Whether to have a backdoor (see doc for the risks).",
  backdoor: false,

  ### "AsyncLibrary",
  core_services: {
  },
  other_services: {
    TestFileCacher:    [["localhost", 27501]]
  },


  ### "Database",

  # "Connection string for the database.",
  database: "postgresql+psycopg2://cmsuser:#{@secrets.fetch(:db_cmsuser_password)}@cms-practice-db.cluster-c9ge2hh8rox6.ap-northeast-1.rds.amazonaws.com/cmsdb",

  # "Whether SQLAlchemy prints DB queries on stdout.",
  database_debug: false,

  # "Whether to use two-phase commit.",
  twophase_commit: false,

  ### "Worker",

  # "Don't delete the sandbox directory under /tmp/ when they",
  # "are not needed anymore. Warning: this can easily eat GB",
  # "of space very soon.",
  keep_sandbox: false,



  ### "Sandbox",

  # "Do not allow contestants' solutions to write files bigger",
  # "than this size (expressed in KB; defaults to 1 GB).",
  max_file_size: 1048576,



  ### "WebServers",

  # "This key is used to encode information that can be seen",
  # "by the user, namely cookies and auto-incremented",
  # "numbers. It should be changed for each",
  # "contest. Particularly, you should not use this example",
  # "for other than testing. It must be a 16 bytes long",
  # "hexadecimal number. You can easily create a key",
  # "calling cmscommon.crypto.get_hex_random_key().",
  secret_key: @secrets.fetch(:cms_secret_key_practice),

  # "Whether Tornado prints debug information on stdout.",
  tornado_debug: false,
  file_log_debug: true,

  ### "ContestWebServer",

  # "Listening HTTP addresses and ports for the CWSs listed above",
  # "in core_services. If you access them through a proxy (acting",
  # "as a load balancer) running on the same host you could put",
  # "127.0.0.1 here for additional security.",
  contest_listen_address: ["127.0.0.1"],
  contest_listen_port:    [8888],

  # "Login cookie duration in seconds. The duration is refreshed",
  # "on every manual request.",
  cookie_duration: 10800,

  # "If CWSs write submissions to disk before storing them in",
  # "the DB, and where to save them. %s = DATA_DIR.",
  submit_local_copy:      true,
  submit_local_copy_path: "%s/submissions/",

  # "The number of proxies that will be crossed before CWSs get",
  # "the request. This is used to decide whether to assume that",
  # "the real source IP address is the one listed in the request",
  # "headers or not. For example, if you're using nginx as a load",
  # "balancer, you will likely want to set this value to 1.",
  num_proxies_used: 0,

  # "Maximum size of a submission in bytes. If you use a proxy",
  # "and set these sizes to large values remember to change",
  # "client_max_body_size in nginx.conf too.",
  max_submission_length: 100000,
  max_input_length: 5000000,

  # "STL documentation path in the system (exposed in CWS).",
  stl_path: "/usr/share/doc/stl-manual/html/",

  ### "AdminWebServer",

  # "Listening HTTP address and port for the AWS. If you access",
  # "it through a proxy running on the same host you could put",
  # "127.0.0.1 here for additional security.",
  admin_listen_address: "127.0.0.1",
  admin_listen_port:    8889,

  # "Login cookie duration for admins in seconds.",
  # "The duration is refreshed on every manual request.",
  admin_cookie_duration: 36000,



  ### "ScoringService",

  # "List of URLs (with embedded username and password) of the",
  # "RWSs where the scores are to be sent. Don't include the",
  # "load balancing proxy (if any), just the backends. If any",
  # "of them uses HTTPS specify a file with the certificates",
  # "you trust.",
  rankings: ["http://citrus:aikotoba@cms-practice-ranking-001.apne1.aws.ioi18.net:80/"],
  https_certfile: nil,



  ### "PrintingService",

  # "Maximum size of a print job in bytes.",
  max_print_length: 10000000,

  # "Printer name (can be found out using 'lpstat -p';",
  # "if null, printing is disabled)",
  printer: nil,

  # "Output paper size (probably A4 or Letter)",
  paper_size: "A4",

  # "Maximum number of pages a user can print per print job",
  # "(excluding the title page). Text files are cropped to this",
  # "length. Too long pdf files are rejected.",
  max_pages_per_job: 10,
  max_jobs_per_user: 10,
  pdf_printing_allowed: false,

  # "This is the end of this file."
  s3_backend_region: 'ap-northeast-1',
  s3_backend_bucket: 'ioi18-cms-files-practice',
  s3_backend_prefix: '',

  # cms::clientlb cookbook
  s3_backend_proxy: 'localhost:18080',
  s3_backend_fetch_base_url: 'http://localhost:10080/ioi18-cms-files-practice/',
  # s3_backend_proxy: 'fproxy.ioi18.net:80',
  # s3_backend_fetch_base_url: 'https://cache.s3-apne1.ioi18.net/ioi18-cms-files-practice/',
  #
}

