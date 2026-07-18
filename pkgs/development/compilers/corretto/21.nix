{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_8,
  jdk21,
  rsync,
  runCommand,
  testers,
}:

let
  corretto = import ./mk-corretto.nix rec {
    inherit
      lib
      stdenv
      rsync
      runCommand
      testers
      ;

    version = "21.0.9.11.1";

    src = fetchFromGitHub {
      owner = "corretto";
      repo = "corretto-21";
      rev = version;
      hash = "sha256-d62rXVgVlOM3M18c8GioFtMi/GhmCEMLQwy/EWAJW7I=";
    };

    gradle = gradle_8;
    jdk = jdk21;
  };
in
corretto.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    ./corretto21-gradle8.patch
  ];

})
