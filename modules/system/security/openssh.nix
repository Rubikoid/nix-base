{ lib, ... }:
{
  services.openssh = {
    enable = true;
    PasswordAuthentication = lib.mkDefault false;
    PermitRootLogin = lib.mkDefault "yes";
  };
}
