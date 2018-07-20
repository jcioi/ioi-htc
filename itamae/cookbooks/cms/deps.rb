include_cookbook 'compilers'

%w(
  build-essential
  fpc
  postgresql-client
  gettext
  python3
  iso-codes
  shared-mime-info
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
