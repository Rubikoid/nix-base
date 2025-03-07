inputs: _raw_lib:
let
  lib_result = _raw_lib.extend (
    lib: prev: {
      r = lib.makeExtensible (
        self:
        let
          loadFile =
            file:
            import file {
              inherit inputs lib loadFile;
              r = self;
            };
        in
        {
          # join strings by comma
          commaJoin = builtins.concatStringsSep ",";

          # i don't remember WTF is it ;(
          mkSecrets =
            basePath: extraAttrs: paths:
            builtins.listToAttrs (
              map (pathName: {
                name = pathName;
                value = {
                  sopsFile = basePath + "/${pathName}";
                } // extraAttrs;
              }) paths
            );

          # i don't remember WTF is it too;(
          mkBinarySecrets =
            basePath: extraAttrs: paths:
            self.mkSecrets basePath ({ format = "binary"; } // extraAttrs) paths;

          # stolen from https://github.com/NixOS/nixpkgs/blob/0c7ffbc66e6d78c50c38e717ec91a2a14e0622fb/nixos/lib/systemd-lib.nix#L264
          # since i can't find way to import it properly ;(
          shellEscape = s: (lib.replaceStrings [ "\\" ] [ "\\\\" ] s);

          makeJobScript =
            pkgs: name: text:
            let
              scriptName =
                lib.replaceStrings
                  [
                    "\\"
                    "@"
                  ]
                  [
                    "-"
                    "_"
                  ]
                  (self.shellEscape name);
              out =
                (pkgs.writeShellScriptBin # fmt
                  scriptName # fmt
                  ''
                    set -e
                    ${text}
                  ''
                ).overrideAttrs
                  (_: {
                    # The derivation name is different from the script file name
                    # to keep the script file name short to avoid cluttering logs.
                    name = "unit-script-${scriptName}";
                  });
            in
            "${out}/bin/${scriptName}";

          # Make docker network...
          mkDockerNet =
            config: name:
            let
              net-name = "${name}-net";
            in
            {
              description = "Create the network bridge for ${name}.";
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];

              serviceConfig.Type = "oneshot";
              script =
                let
                  dockercli = "${config.virtualisation.docker.package}/bin/docker";
                in
                ''
                  # ${net-name} network
                  check=$(${dockercli} network ls | grep "${net-name}" || true)
                  if [ -z "$check" ]; then
                    ${dockercli} network create ${net-name}
                  else
                    echo "${net-name} already exists in docker"
                  fi
                '';
            };

          #
          extender =
            _lib: cb:
            _lib.extend (
              lib: prev: {
                r = prev.r.extend (r: prevr: (cb { inherit lib prev r prevr; }));
              }
            );

          modules = lib.r.findModulesV2 (../. + "/modules");

          debug = loadFile ./debug.nix;
          merge = loadFile ./merge.nix;
          moduleSystem = loadFile ./moduleSystem.nix;
          helpers = loadFile ./helpers;
          system = loadFile ./system;

          mkFlake =
            passingNixpkgs: argFactory:
            let
              inherit (self.nixInit passingNixpkgs) pkgsFor forEachSystem mkSystem;
              eachSystemArgs = forEachSystem (ops: argFactory (ops // { }));
              argExtractor = arg: lib.genAttrs self.supportedSystems (system: eachSystemArgs.${system}.${arg});
            in
            {
              lib = lib_result;
              devShells = argExtractor "devShells";
              packages = argExtractor "packages";
            };

          inherit (self.debug) strace straceSeq straceSeqN;
          inherit (self.merge) recursiveMerge mkMergeTopLevel;
          inherit (self.moduleSystem) findModules findModulesV2;
          inherit (self.helpers) python;
          inherit (self.system)
            # some simple system related things
            supportedSystems
            defaultSystem
            overlays
            rawReadSystem
            readSystem
            # filters per type
            isDarwinFilter
            isWSLFilter
            isVMFilter
            # things for dealing with host parsing
            sanitizeHostname
            getHostOptions
            # preparing nixpkgs...
            rawPkgsFor
            # more hosts thingns
            findAllHosts
            forEachHost
            # more every system things
            rawForEachSystem
            # more system preparing
            nixosConfigGenerator
            mkSystemOnlyConfig
            rawMkSystem
            # to call with nixpkgs, if you want to use another nixpkgs
            nixInit
            # exported from nixInit
            pkgsFor
            forEachSystem
            mkSystem
            ;
        }
      );
    }
  );
in
lib_result
