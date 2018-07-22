user "sei1tani", :path=>"/" do
  login_profile :password_reset_required=>true

  attached_managed_policies(
    "arn:aws:iam::aws:policy/AdministratorAccess",
  )

end


