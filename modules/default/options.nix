# stolen from https://github.com/balsoft/nixos-config/blob/master/modules/devices.nix
{ pkgs, lib, config, ... }:

with lib;
with types;
{
  options = {
    rubikoid.secrets.enable = lib.mkEnableOption "secrets thing";
    rubikoid.default-packages.enable = lib.mkEnableOption "default packages option";

    system-arch-name = lib.mkOption { type = types.str; };

    device = mkOption { type = str; };
    deviceSecrets = mkOption { type = path; };

    user = mkOption { type = str; };
    userSecrets = mkOption { type = path; };

    isDarwin = mkOption {
      type = bool;
      default = false;
    };

    isWSL = mkOption {
      type = bool;
      default = false;
    };

    deviceSpecific = {
      # most of it i don't need...
      # isLaptop = mkOption {
      #   type = bool;
      #   default =
      #     !isNull (builtins.match ".*Laptop" config.networking.hostName);
      # };
      # isPhone = mkOption {
      #   type = bool;
      #   default = !isNull (builtins.match ".*Phone" config.networking.hostName);
      # };
      # devInfo = {
      #   cpu = {
      #     arch = mkOption { type = enum [ "x86_64" "aarch64" ]; };
      #     vendor = mkOption { type = enum [ "amd" "intel" "broadcom" ]; };
      #     clock = mkOption { type = int; };
      #     cores = mkOption { type = int; };
      #   };
      #   drive = {
      #     type = mkOption { type = enum [ "hdd" "ssd" ]; };
      #     speed = mkOption { type = int; };
      #     size = mkOption { type = int; };
      #   };
      #   ram = mkOption { type = int; };
      #   legacy = mkOption { type = bool; default = false; };
      #   bigScreen = mkOption {
      #     type = bool;
      #     default = true;
      #   };
      # };
      # # Whether machine is powerful enough for heavy stuff
      # goodMachine = with config.deviceSpecific;
      #   mkOption {
      #     type = bool;
      #     default = devInfo.cpu.clock * devInfo.cpu.cores >= 4000
      #       && devInfo.drive.size >= 100 && devInfo.ram >= 8;
      #   };
      # isHost = mkOption {
      #   type = bool;
      #   default = false;
      # };
      # bigScreen = mkOption {
      #   type = bool;
      #   default = config.deviceSpecific.devInfo ? bigScreen;
      # };
    };
  };

  config = {
    rubikoid.default-packages.enable = true; # default ;)
  };
}
