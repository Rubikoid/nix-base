{
  lib,
  r,
  ...
}:
{
  globalOverrides = pkgs: [
    (
      _final: _prev:
      let
        fixDeps =
          pkgName: extraDeps:
          _prev.${pkgName}.overrideAttrs (old: {
            # nativeBuildInputs = old.nativeBuildInputs ++ [ ];
            buildInputs = (old.buildInputs or [ ]) ++ extraDeps;
          });

        fixSetupTools = pkgName: fixDeps pkgName [ _final.setuptools ];
      in
      {
        # Implement build fixups here.
        jsbeautifier = fixSetupTools "jsbeautifier";
        cssbeautifier = fixSetupTools "cssbeautifier";
        editorconfig = fixSetupTools "editorconfig";
        www-authenticate = fixSetupTools "www-authenticate";
        "ruamel.yaml" = fixSetupTools "ruamel.yaml";
        "ruamel.yaml.clib" = fixSetupTools "ruamel.yaml.clib";
        "ruamel-yaml-clib" = fixSetupTools "ruamel-yaml-clib";
        psycopg2 = fixDeps "psycopg2" [
          _final.setuptools
          pkgs.postgresql
        ];
        psycopg2-binary = fixDeps "psycopg2-binary" [ _final.setuptools ];
      }
    )
  ];

  setupPythonEnvs =
    {
      name,
      source,
      pkgs,
      inputs,
      sourcePreference ? "wheel", # or sourcePreference = "sdist";
      python ? null, # or func
      overrides ? _: _: { },
      ...
    }@args:
    let
      inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;

      workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = source; };
      overlay = workspace.mkPyprojectOverlay { inherit sourcePreference; };

      # dark magic.
      # Create an overlay enabling editable mode for all local dependencies.
      editableOverlay = workspace.mkEditablePyprojectOverlay {
        # Use environment variable
        root = "$REPO_ROOT";
        # Optional: Only enable editable for these packages
        # members = [ "hello-world" ];
      };

      workingPython =
        if python != null then
          python pkgs
        else
          lib.head (
            pyproject-nix.lib.util.filterPythonInterpreters {
              inherit (workspace) requires-python;
              inherit (pkgs) pythonInterpreters;
            }
          );

      pyprojectOverrides = lib.composeManyExtensions (
        (lib.r.helpers.python.globalOverrides pkgs) ++ [ overrides ]
      );

      defaultPythonSet =
        (pkgs.callPackage pyproject-nix.build.packages { python = workingPython; }).overrideScope
          (
            lib.composeManyExtensions [
              pyproject-build-systems.overlays.default
              overlay
              pyprojectOverrides
            ]
          );
      editablePythonSet = defaultPythonSet.overrideScope editableOverlay;

      pythonEnv = defaultPythonSet.mkVirtualEnv "${name}-env" workspace.deps.default;
      editablePythonEnv = editablePythonSet.mkVirtualEnv "${name}-dev-env" workspace.deps.all;

      mkResult =
        {
          pySet,
          pyEnv,
          packages ? [ ],
          shellHook ? "",
        }:
        {
          inherit pySet pyEnv;

          packages = [
            pyEnv
            pkgs.uv
          ]
          ++ packages;

          shellHook = ''
            # Undo dependency propagation by nixpkgs.
            unset PYTHONPATH

            # link venv
            unlink ./.venv; ln -sf ${pyEnv} ./.venv
          '';
          env = {
            UV_NO_SYNC = "1";
            UV_PYTHON = pySet.python.interpreter;
            UV_PYTHON_DOWNLOADS = "never";
          };
        };
    in
    {
      inherit workspace overlay pyprojectOverrides;

      simple = mkResult {
        pySet = defaultPythonSet;
        pyEnv = pythonEnv;
      };
      editable = mkResult {
        pySet = editablePythonSet;
        pyEnv = editablePythonEnv;
      };
    };
}
