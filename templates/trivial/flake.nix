{
  inputs = {
    nixpkgs.url = "nixpkgs";
    base = {
      url = "github:rubikoid/nix-base";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, base, ... }@inputs:
    let
      lib = base.lib.r.extender base.lib (
        { lib, prev, r, prevr }:
        {

        }
      );
    in
    {
      devShells = lib.r.forEachSystem (
        { system, pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [ ];

            nativeBuildInputs = with pkgs; [ ];

            shellHook = '''';
          };
        }
      );
    };
}
