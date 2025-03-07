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
    environment.systemPackages = lib.mkIf config.rubikoid.default-packages.enable (
      with pkgs;
      [
        vim
        git
        just
      ]
    );

    networking = {
      hostName = lib.r.strace config.device;
    };
  };
}
