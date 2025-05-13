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
          pkgName:
          extraDeps:
          _prev.${pkgName}.overrideAttrs (old: {
            # nativeBuildInputs = old.nativeBuildInputs ++ [ ];
            buildInputs = (old.buildInputs or [ ]) ++ extraDeps;
          });
          
        fixSetupTools =
          pkgName:
          fixDeps pkgName [ _final.setuptools ];
      in
      {
        # Implement build fixups here.
        jsbeautifier = fixSetupTools "jsbeautifier";
        cssbeautifier = fixSetupTools "cssbeautifier";
        editorconfig = fixSetupTools "editorconfig";
        psycopg2 = fixDeps "psycopg2" [ _final.setuptools pkgs.postgresql ] ;
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
      python ? pkgs: pkgs.python312,
      overrides ? _: _: { },
      ...
    }@args:
    let
      inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;

      # not quite sure I need this
      # but according to https://nix.dev/guides/best-practices.html#reproducible-source-paths ...?
      cleanSource = builtins.path {
        path = source;
        name = "${name}-python-source";
      };

      workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = cleanSource; };
      overlay = workspace.mkPyprojectOverlay { inherit sourcePreference; };

      pyprojectOverrides = lib.composeManyExtensions ((r.helpers.python.globalOverrides pkgs) ++ [ overrides ]);

      pythonSet =
        (pkgs.callPackage pyproject-nix.build.packages { python = (python pkgs); }).overrideScope
          (
            lib.composeManyExtensions [
              pyproject-build-systems.overlays.default
              overlay
              pyprojectOverrides
            ]
          );

      # dark magic.
      # Create an overlay enabling editable mode for all local dependencies.
      editableOverlay = workspace.mkEditablePyprojectOverlay {
        # Use environment variable
        root = "$REPO_ROOT";
        # Optional: Only enable editable for these packages
        # members = [ "hello-world" ];
      };

      editablePythonSet = pythonSet.overrideScope editableOverlay;

      pythonEnv = pythonSet.mkVirtualEnv "${name}-env" workspace.deps.default;
      editablePythonEnv = editablePythonSet.mkVirtualEnv "${name}-dev-env" workspace.deps.all;
    in
    {
      inherit cleanSource workspace overlay pyprojectOverrides;

      simple = {
        set = pythonSet;
        env = pythonEnv;

        packages = with pkgs; [
          pythonEnv
          pkgs.uv
        ];

        shellHook = ''
          # Undo dependency propagation by nixpkgs.
          unset PYTHONPATH

          # disable uv angry things
          export UV_NO_SYNC=1

          unlink ./.venv; ln -sf ${pythonEnv} ./.venv
        '';
      };

      editable = {
        set = editablePythonSet;
        env = editablePythonEnv;

        packages = with pkgs; [
          editablePythonEnv
          pkgs.uv
        ];

        shellHook = ''
          # Undo dependency propagation by nixpkgs.
          unset PYTHONPATH

          # Get repository root using git. This is expanded at runtime by the editable `.pth` machinery.
          export REPO_ROOT=$(git rev-parse --show-toplevel)

          # disable uv angry things
          export UV_NO_SYNC=1

          unlink ./.venv; ln -sf ${editablePythonEnv} ./.venv
        '';
      };
    };
}
