{
  description = "Base NixOS config part";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs =
    { self, ... }@inputs:
    {
      lib = import ./lib inputs inputs.nixpkgs.lib;

      templates = {
        trivial = {
          path = ./templates/trivial;
          description = "A very basic flake";
        };

        py-uv = {
          path = ./templates/py-uv;
          description = "Python flake, powered by uv";
        };
      };
    };
}
