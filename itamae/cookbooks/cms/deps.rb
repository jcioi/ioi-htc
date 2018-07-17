%w(
  build-essential
  openjdk-8-jre
  openjdk-8-jdk
  fpc
  postgresql-client
  gettext
  python3
  iso-codes
  shared-mime-info
  stl-manual
  cgroup-lite
  python3-dev
  libpq-dev
  libcups2-dev
  libyaml-dev
  libffi-dev
  libcap-dev
  python3-pip
  python3-venv
  texlive-latex-base
  a2ps
).each do |dep|
  package dep
end
