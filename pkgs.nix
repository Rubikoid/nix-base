inputs: final: prev: rec {
  nixfmt-rubi-style = final.callPackage ./pkgs/nixfmt-patched.nix { };
  octodns-selectel = final.python312Packages.callPackage ./pkgs/octodns-selectel.nix { };
}
