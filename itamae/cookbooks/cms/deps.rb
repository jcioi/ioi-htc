%w(
  build-essential
  openjdk-8-jre
  openjdk-8-jdk
  fpc
  postgresql-client
  gettext
  python2.7
  iso-codes
  shared-mime-info
  stl-manual
  cgroup-lite
  python-dev
  libpq-dev
  libcups2-dev
  libyaml-dev
  libffi-dev
  python-pip
  texlive-latex-base
  a2ps
  gcj-jdk
  python-virtualenv
).each do |dep|
  package dep
end