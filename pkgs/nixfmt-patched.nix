{
  pkgs,
  lib,
  ...
}:
let
  patch = pkgs.fetchpatch2 {
    url = "https://github.com/Rubikoid/nixfmt/pull/1.patch";
    sha256 = "sha256-YixtONu7Vc6vI6CMZXRKGU/p4s0d75bjfuQDemAhbQ8="; # "sha256-0x9VBFuQtc36g4LSRZanb/9XJ6fni6sCiWQyxue8pog=";
  };
in
pkgs.nixfmt-rfc-style.overrideAttrs (old: {
  pname = "nixfmt-rubi-style";
  patches = (old.patches or [ ]) ++ [ patch ];
})
