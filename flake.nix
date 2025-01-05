{
  description = "Base NixOS config part";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }@inputs:
    {
      lib = import ./lib inputs nixpkgs.lib;

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
