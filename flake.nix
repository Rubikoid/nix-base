{
  description = "Base NixOS config part";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }@inputs:
    {
      lib = import ./lib inputs nixpkgs.lib;
    };
}
