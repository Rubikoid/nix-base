{
  description = "Base NixOS config part";

  inputs = { };

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
