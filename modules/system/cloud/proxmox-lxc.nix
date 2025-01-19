{ modulesPath, lib, ... }:

{
  imports = [
    "${toString modulesPath}/virtualisation/proxmox-lxc.nix"
  ];

  proxmoxLXC = {
    manageNetwork = lib.mkDefault false;
    privileged = lib.mkDefault false;
    manageHostName = lib.mkDefault true;
  };
}
