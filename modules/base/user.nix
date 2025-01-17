{
  inputs,
  pkgs,
  lib,
  config,
  secrets,
  device,
  mode,
  ...
}:

{
  # programs.home-manager.enable = true; # idk why i need that
  home =
    let
      baseHomePath = if lib.hasPrefix "Darwin" mode then "/Users" else "/home";
    in
    {
      username = config.user;
      homeDirectory = if (config.user != "root") then "${baseHomePath}/${config.user}" else "/root";
      stateVersion = "24.05";
    };
}
