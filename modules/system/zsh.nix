{ pkgs, lib, config, ... }:

let
  cfg = config.rubikoid.zsh;
in
{
  options.rubikoid.zsh = {
    omz = lib.mkEnableOption "omz";
  };

  config = {
    users.defaultUserShell = pkgs.zsh;
    environment.pathsToLink = [ "/share/zsh" ];

    programs.zsh = {
      enable = true;

      interactiveShellInit = "";

      ohMyZsh = {
        enable = cfg.omz;

        theme = lib.mkDefault "candy";

        plugins = [
          "systemd"
        ];
      };
    };
  };
}
