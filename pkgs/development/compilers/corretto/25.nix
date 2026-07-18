{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_9,
  jdk25,
  pandoc,
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

    version = "25.0.1.9.1";

    src = fetchFromGitHub {
      owner = "corretto";
      repo = "corretto-25";
      rev = version;
      hash = "sha256-eAjepqxp5LVQgP/HcxwwdjbXxy5jUOJC4HYntcHNX0o=";
    };

    extraNativeBuildInputs = [ pandoc ];
    gradle = gradle_9;
    jdk = jdk25;
  };
in
corretto.overrideAttrs (
  final: prev: {
    patches = (prev.patches or [ ]) ++ [
      # See patches in openjdk/generic.nix.
      ./remove_removal_of_wformat_during_test_compilation.patch
    ];
  }
)
