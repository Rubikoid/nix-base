{
  inputs,
  lib,
  pkgs,
  config,
  secretsModule,
  ...
}:
let
  cfg = config.rubikoid;
in
{
  imports = [ secretsModule ];

  config = {
    rubikoid.secrets.enable = lib.mkDefault true;

    # must have packages
    environment.systemPackages = with pkgs; [
      vim
      git
      just
    ];

    networking = {
      hostName = lib.r.strace config.device;
    };
  };
}
