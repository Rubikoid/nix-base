{ modulesPath, lib, ... }:

{
  imports = [
    "${toString modulesPath}/virtualisation/proxmox-lxc.nix"
  ];

  nix.optimise.automatic = lib.mkOverride 999 true;
  proxmoxLXC = {
    manageNetwork = lib.mkDefault false;
    privileged = lib.mkDefault false;
    manageHostName = lib.mkDefault true;
  };
}
