{
  lib,
  stdenv,
  callPackage,
  ruby,
  ...
}:
let
  mkDerivation =
    { name, ... }@argSet:
    derivation {
      inherit name;

      args = [
        "-c"
        "echo  $(<$textPath) > $out"
      ];

      builder = stdenv.shell;
      passAsFile = [ "text" ];
      system = stdenv.hostPlatform.system;

      text = (
        builtins.toJSON (
          lib.filterAttrs (
            n: v:
            builtins.elem n [
              "name"
              "system"
            ]
          ) argSet
        )
      );
    };
  fetchurl =
    {
      url ? "",
      urls ? [ ],
      ...
    }:
    "fetchurl:${if urls == [ ] then url else builtins.head urls}";

  stdenv' = stdenv // {
    inherit mkDerivation;
    stubbed = true;
  };
  ruby' = ruby // {
    stdenv = stdenv';
    stubbed = true;
  };
in
{
  buildRubyGem = callPackage ../gem {
    inherit fetchurl;
    ruby = ruby';
  };

  ruby = ruby';
  stdenv = stdenv';
}
