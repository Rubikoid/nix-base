inputs: final: prev: rec {
  nixfmt-rubi-style = final.callPackage ./pkgs/nixfmt-patched.nix { };
}
