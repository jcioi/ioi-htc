node.reverse_merge!(
  kea: {
    interfaces: %w(*),
    relay_only: true,
  },
)

include_role 'base'
include_cookbook 'kea'

def generate_reservation(machines, role, opt={})
  machines.map do |machine|
    opt.merge('hw-address' => machine.fetch(:mac), 'ip-address' => machine.fetch(role))
  end
end

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
        srv: [
          200, '10.18.8.0/22', '10.18.8.1', '10.18.9.0-10.18.11.250',
          "match-client-id" => false,
          option_data: [
            {
              name: "tftp-server-name",
              code: 66,
              space: "dhcp4",
              "csv-format" => true,
              data: "10.18.8.20",
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
              "ip-address" => '10.18.8.10',
              "hostname"   => "cms-dev-worker-1.srv.#{node.fetch(:site_domain)}",
              "next-server"=> '10.18.8.20',
            },
            {
              "hw-address" => 'd8:c4:97:24:33:ed',
              "ip-address" => '10.18.8.11',
              "hostname"   => "cms-dev-worker-2.srv.#{node.fetch(:site_domain)}",
              "next-server"=> '10.18.8.20',
            },
            {
              "hw-address" => 'd8:c4:97:24:34:9a',
              "ip-address" => '10.18.8.12',
              "hostname"   => "cms-dev-worker-3.srv.#{node.fetch(:site_domain)}",
              "next-server"=> '10.18.8.20',
            },
            {
              "hw-address" => 'd8:c4:97:53:53:82',
              "ip-address" => '10.18.8.13',
              "hostname"   => "cms-dev-worker-4.srv.#{node.fetch(:site_domain)}",
              "next-server"=> '10.18.8.20',
            },
            {
              "hw-address" => '52:54:00:4d:5d:6d',
              "ip-address" => '10.18.8.18',
              "hostname"   => "cms-prd-worker-template.srv.#{node.fetch(:site_domain)}",
              "next-server"=> '10.18.8.20',
            },
            {
              "hw-address" => '52:54:00:7e:8e:9e',
              "ip-address" => '10.18.8.19',
              "hostname"   => "cms-dev-worker-template.srv.#{node.fetch(:site_domain)}",
              "next-server"=> '10.18.8.20',
            },
            {
              "hw-address" => '9a:ba:01:63:21:c6',
              "ip-address" => '10.18.8.20',
              "hostname"   => "fog-001.srv.#{node.fetch(:site_domain)}",
            },
            {
              "hw-address" => 'd8:49:2f:f9:3f:48',
              "ip-address" => '10.18.8.31',
              "hostname"   => "prn-ref-001.srv.#{node.fetch(:site_domain)}",
            },
            {
              "hw-address" => 'd8:49:2f:f9:3f:52',
              "ip-address" => '10.18.8.32',
              "hostname"   => "prn-ref-002.srv.#{node.fetch(:site_domain)}",
            },
            {
              "hw-address" => 'd8:49:2f:f9:3f:fd',
              "ip-address" => '10.18.8.33',
              "hostname"   => "prn-ref-003.srv.#{node.fetch(:site_domain)}",
            },
            {
              "hw-address" => 'd8:49:2f:f9:40:02',
              "ip-address" => '10.18.8.34',
              "hostname"   => "prn-ref-004.srv.#{node.fetch(:site_domain)}",
            },
            {
              "hw-address" => 'd8:49:2f:f9:3f:d7',
              "ip-address" => '10.18.8.35',
              "hostname"   => "prn-ref-005.srv.#{node.fetch(:site_domain)}",
            },
          ] + generate_reservation(
            node[:onsite_machines_data], :cmsworker,
            'next-server' => '10.18.8.20',
          )
        ],
        guest: [300, '10.18.32.0/21', '10.18.32.1', '10.18.33.0-10.18.39.250'],
        adm: [301, '10.18.40.0/21', '10.18.40.1', '10.18.41.0-10.18.47.250'],
        life: [310, '10.18.56.0/22', '10.18.56.1', '10.18.57.0-10.18.59.250'],
        arena: [
          320, '10.18.60.0/22', '10.18.60.1', '10.18.61.0-10.18.63.250',
          "match-client-id" => false,
          option_data: [
            {
              name: "tftp-server-name",
              code: 66,
              space: "dhcp4",
              "csv-format" => true,
              data: "10.18.60.20",
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
          ] + generate_reservation(
            node[:onsite_machines_data], :contestant,
            'next-server' => '10.18.60.20',
          ),
        ],
        conf: [
          800, '10.18.64.0/22', '10.18.64.1', '10.18.65.0-10.18.67.250',
          reservation: [
            {
              "hw-address" => 'd8:49:2f:f9:40:fa',
              "ip-address" => '10.18.64.31',
              "hostname"   => "prn-conf-001.conf.#{node.fetch(:site_domain)}",
            },
            {
              "hw-address" => 'd8:49:2f:f9:3f:42',
              "ip-address" => '10.18.64.32',
              "hostname"   => "prn-conf-002.conf.#{node.fetch(:site_domain)}",
            },
            {
              "hw-address" => 'd8:49:2f:f9:40:f4',
              "ip-address" => '10.18.64.33',
              "hostname"   => "prn-conf-003.conf.#{node.fetch(:site_domain)}",
            },
            {
              "hw-address" => 'd8:49:2f:f9:40:90',
              "ip-address" => '10.18.64.34',
              "hostname"   => "prn-conf-004.conf.#{node.fetch(:site_domain)}",
            },
          ],
        ],
        lab: [
          900, '10.18.96.0/24', '10.18.96.1', '10.18.96.200-10.18.96.250',
        ],
      }.map do |name, v|
        id, prefix, gw, pool, opt = v
        opt ||= {}
        reservation = opt.delete(:reservation)
        option_data = opt.delete(:option_data) || []

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
        }.merge(opt)
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

