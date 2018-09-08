execute "curl https://packagecloud.io/gpg.key | apt-key add -" do
  not_if "apt-key export C2E73424D59097AB|grep -q PGP"
end
