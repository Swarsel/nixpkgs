{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  isl_0_23,
  libmpc,
  mpfr,
  ncurses,
  runCommand,
  xz,
}:
let
  version = "7.1.0";
in
runCommand "sfpi-${version}"
  {
    inherit version;

    src =
      {
        aarch64-linux = fetchurl {
          hash = "sha256-MzI159hiitk1iyeGfQaDOQZhqGjfafpCMz6zmM3HrYs=";
          url = "https://github.com/tenstorrent/sfpi/releases/download/v${version}/sfpi_${version}_aarch64.txz";
        };

        x86_64-linux = fetchurl {
          hash = "sha256-rQfFveg1ht+jLfk3ZOJadX26+ODE3WW5E0/18eIl7RQ=";
          url = "https://github.com/tenstorrent/sfpi/releases/download/v${version}/sfpi_${version}_x86_64.txz";
        };
      }
      ."${stdenv.hostPlatform.system}" or (throw "SFPI does not support ${stdenv.hostPlatform.system}");

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      ncurses
      isl_0_23
      mpfr
      libmpc
      xz
    ];
  }
  ''
    runPhase unpackPhase
    cp -r ../"$sourceRoot" "$out"
    runPhase fixupPhase
  ''
