node.reverse_merge!(
  kea: {
    interfaces: %w(*),
    relay_only: true,
  },
)

include_role 'base'
include_cookbook 'kea'

conf = {
  Dhcp4: {
    "control-socket" => {
      "socket-type" => "unix",
      "socket-name" => "/run/kea/kea.sock",
    },
    "interfaces-config" => {
      interfaces: node[:kea][:interfaces],
      "dhcp-socket-type" => node[:kea][:relay_only] ? 'udp' : 'raw',
    },
    "lease-database" => {
      type: "memfile",
      persist: true,
      name: "/var/lib/kea/dhcp4.leases",
    },
    "expired-leases-processing" => {
      "reclaim-timer-wait-time" => 10,
      "flush-reclaimed-timer-wait-time" => 25,
      "hold-reclaimed-time" => 1800,
      "max-reclaim-leases" => 500,
      "max-reclaim-time" => 250,
      "unwarned-reclaim-cycles" => 2,
    },
    "valid-lifetime" => 720*4,
    "renew-timer" => 540*4,
    "rebind-timer" => 660*4,
    subnet4: [
      {
        guest: [300, '10.18.32.0/21', '10.18.32.1', '10.18.33.0-10.18.39.250'],
        adm: [301, '10.18.40.0/21', '10.18.40.1', '10.18.41.0-10.18.47.250'],
        life: [310, '10.18.56.0/22', '10.18.56.1', '10.18.57.0-10.18.59.250'],
        arena: [320, '10.18.60.0/22', '10.18.60.0', '10.18.61.0-10.18.63.250'],
        lab: [
          900, '10.18.96.0/24', '10.18.96.1', '10.18.96.200-10.18.96.250',
          option_data: [
            {
              name: "tftp-server-name",
              code: 66,
              space: "dhcp4",
              "csv-format" => true,
              data: "10.18.96.20",
            },
            {
              name: "boot-file-name",
              code: 67,
              space: "dhcp4",
              "csv-format" => true,
              data: "ipxe.efi",
            },
          ],
          reservation: [
            {
              "hw-address" => 'd8:c4:97:24:37:c6',
              "ip-address" => '10.18.96.10',
              "hostname"   => "cms-dev-worker-1.lab.#{node.fetch(:site_domain)}",
            },
            {
              "hw-address" => 'd8:c4:97:24:33:ed',
              "ip-address" => '10.18.96.11',
              "hostname"   => "cms-dev-worker-2.lab.#{node.fetch(:site_domain)}",
            },
            {
              "hw-address" => 'a4:bf:01:50:df:7c',
              "ip-address" => '10.18.96.20',
              "hostname"   => "fog-001.lab.#{node.fetch(:site_domain)}",
            },
          ],
        ],
      }.map do |name, v|
        id, prefix, gw, pool, opt = v
        opt ||= {}
        reservation = opt[:reservation]
        option_data = opt[:option_data] || []

        {
          subnet: prefix,
          id: id,
          pools: [
            pool: pool,
          ],
          "option-data" => option_data + [
            {
              name: "routers",
              code: 3,
              space: "dhcp4",
              "csv-format" => true,
              data: gw,
            },
            #{ name: "log-servers", space: "dhcp4", "csv-format" => true, data: "10.25.128.3",
            {
              name: "domain-name",
              code: 15,
              space: "dhcp4",
              "csv-format" => true,
              data: "#{name}.#{node.fetch(:site_domain)}",
            }
          ],
          reservations: reservation ? reservation : [
            #node[:hosts_data].select { |_| _[:network] == 'lan' && _[:mac] }.map { |_|
            #  {
            #    "hw-address" => _[:mac].downcase,
            #    "ip-address" => _[:ip],
            #    "hostname"   => "#{_[:name]}.venue.l.#{node.fetch(:site_domain)}",
            #  }
            #}
          ].flatten,
        }
      end,
    ].flatten,
    "option-data" => [
      {
        name: "domain-name-servers",
        code: 6,
        space: "dhcp4",
        "csv-format" => true,
        data: node.fetch(:resolvers_global).join(?,), # comma separated
      },
    ],
  },
  Logging: {
    loggers: [
      {
        name: "kea-dhcp4",
        output_options: [
          {
            output: "/var/log/kea/kea.log",
            maxsize: 1000000,
          },
        ],
        severity: "INFO",
      },
    ],
  },
}

directory "/var/log/kea" do
  owner 'root'
  group 'root'
  mode  '0755'
end

directory '/etc/systemd/system/kea-dhcp4-server.service.d' do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file '/etc/systemd/system/kea-dhcp4-server.service.d/directory.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end


file "/etc/kea/kea-dhcp4.conf" do
  content "#{conf.to_json}\n"
  owner 'root'
  group 'root'
  mode  '0644'
end

service "kea-dhcp4-server.service" do
  action [:enable, :start]
end

include_cookbook 'awscli'

remote_file "/usr/bin/ioi-upload-leases" do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file "/etc/systemd/system/ioi-upload-leases.service" do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

remote_file "/etc/systemd/system/ioi-upload-leases.timer" do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service "ioi-upload-leases.timer" do
  action [:enable, :start]
end

