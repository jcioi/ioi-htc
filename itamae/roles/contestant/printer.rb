include_cookbook 'ioiprint-client'

execute 'setup ioiprint' do
  command %W{
    lpadmin -p ioiprint
      -v #{node.dig(:contestant, :ioiprint_uri)}
      -m lsb/usr/cupsfilters/Generic-PDF_Printer-PDF.ppd
      -o printer-error-policy=retry-current-job
      -o PageSize=A4
      -o PageSize-default=A4
      -o overridea4withletter=no
      -o overridea4withletter-default=no
      -E
  }.shelljoin
  not_if 'lpstat -v ioiprint'
end

execute 'deafult ioiprint' do
  command 'lpadmin -d ioiprint'
  only_if 'lpstat -d | grep -Fq "no system default destination"'
end

file 'modify ioiprint' do
  action :edit
  path '/etc/cups/ppd/ioiprint.ppd'
  block do |content|
    content.gsub!(%r{^\*(?:PageSize|PageRegion|ImageableArea|PaperDimension) (?!A4/).*\n}, '')
  end
end

file 'set PAPERSIZE' do
  action :edit
  path '/etc/environment'
  block do |content|
    if content =~ /^PAPERSIZE=/
      content.gsub!(/^PAPERSIZE=.*$/, 'PAPERSIZE=a4')
    else
      content << "PAPERSIZE=a4\n"
    end

    if content =~ /^LC_PAPER=/
      content.gsub!(/^LC_PAPER=.*$/, 'LC_PAPER=en_GB.UTF-8')
    else
      content << "LC_PAPER=en_GB.UTF-8\n"
    end
  end
end

file '/etc/papersize' do
  owner 'root'
  group 'root'
  mode '0644'
  content "a4\n"
end
