{
  pkgs,
  lib,
  config,
  inputs,
  secrets,
  ...
}:

{
  options.rubikoid.nix = { };

  config = {
    nix = {
      package = pkgs.nix;

      registry = {
        n.flake = inputs.nixpkgs;
        nixpkgs.flake = inputs.nixpkgs;
      };

      # linking hardlinks inside store
      # good thing
      optimise.automatic = lib.mkDefault true;

      gc = {
        automatic = lib.mkDefault true;
        dates = lib.mkIf (!config.isDarwin) "weekly";
        options = "--delete-older-than 7d";
      };

      # nix command, flakes
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          # "repl-flake"
        ];

        flake-registry = lib.mkForce ""; # бе-бе-бе, я сам себе registry
      };
    };
  };
}
