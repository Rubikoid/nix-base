{
  inputs = {
    nixpkgs.url = "nixpkgs";

    base = {
      url = "github:rubikoid/nix-base"; # "base"; # github:rubikoid/nix-base
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix/b0d513eeeebed6d45b4f2e874f9afba2021f7812";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix/661dadc1e3ff53142e1554172ab60c667de2c1d5";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs/042904167604c681a090c07eb6967b4dd4dae88c";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, base, ... }@inputs:
    let
      lib = base.lib.r.extender base.lib ({ lib, prev, r, prevr }: { });
    in
    lib.r.mkFlake nixpkgs (
      { system, pkgs, ... }:
      let
        pythonOptions = {
          name = "change-me";
          source = ./.;

          sourcePreference = "wheel";
          # python = pkgs: pkgs.python312;

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
          default = pkgs.mkShell {
            packages = (with pkgs; [ ]) ++ pythonSetup.editable.packages;

            nativeBuildInputs = with pkgs; [ ];

            shellHook = ''
              ${pythonSetup.editable.shellHook}
            '';
          };

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

        };
      }
    );
}
