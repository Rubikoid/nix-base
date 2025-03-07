{
  inputs = {
    nixpkgs.url = "nixpkgs";

    base = {
      url = "github:rubikoid/nix-base"; # "base"; # github:rubikoid/nix-base
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
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
      let
        pythonOptions = {
          name = "example";
          source = ./.;

          sourcePreference = "wheel";
          python = pkgs: pkgs.python312;

          overrides = _: _: { };

          inherit inputs pkgs;
        };

        pythonSetup = lib.r.helpers.python.setupPythonEnvs pythonOptions;
      in
      {
        packages = {
          default = pythonSetup.simple.env;
        };

        devShells = {
          # It is of course perfectly OK to keep using an impure virtualenv workflow and only use uv2nix to build packages.
          # This devShell simply adds Python and undoes the dependency leakage done by Nixpkgs Python infrastructure.
          impure = pkgs.mkShell {
            packages = [
              pkgs.python312
              pkgs.uv
            ];
            shellHook = ''
              unset PYTHONPATH
            '';
          };

          default = pkgs.mkShell {
            packages =
              (with pkgs; [

              ])
              ++ pythonSetup.editable.packages;

            nativeBuildInputs = with pkgs; [

            ];

            shellHook = ''
              ${pythonSetup.editable.shellHook}
            '';
          };
        };
      }
    );
}
