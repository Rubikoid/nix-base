rec {
  nixpkgs = import <nixpkgs> { };
  lib = import ./lib { inherit nixpkgs; } nixpkgs.lib;

  test-lib = lib.r.extender lib ({ lib, prev, r, prevr, ... }: { });

  modules = builtins.listToAttrs (lib.r.findModules (./. + "/modules"));
  modules2 = lib.r.findModulesV2 (./. + "/modules");
}
