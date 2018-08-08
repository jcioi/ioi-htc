node.reverse_merge!(
  cups_pdf: {
    out: '${HOME}/PDF',
  },
)

package 'printer-driver-cups-pdf' do
  action :install
end

template '/etc/cups/cups-pdf.conf' do
  owner 'root'
  group 'root'
  mode '644'
end
