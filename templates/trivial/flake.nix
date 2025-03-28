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
          extended = 1;
        }
      );
    in
    lib.r.mkFlake nixpkgs (
      { system, pkgs, ... }:
      {
        packages = { };
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [ ];

            nativeBuildInputs = with pkgs; [ ];

            shellHook = '''';
          };
        };
      }
    );
}
