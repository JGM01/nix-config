let
  trollserver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBW4+aQ5XRV8wm68Qru921tspeOSeGCesCM2tFYLaUG root@trollserver"; 
  mac = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAU6/+B8Lrn9O3AB73CztMyFYVpwTsPrpg4eRcM/2l1 trollbook"; 
in
{
  "trolluser-password.age".publicKeys = [ trollserver mac ];
  "wubbzee-webhook-secret.age".publicKeys = [ trollserver mac ];
  "wubbzee-deploy-key.age".publicKeys = [ trollserver mac ];
}
