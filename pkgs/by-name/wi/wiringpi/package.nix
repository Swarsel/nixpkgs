{
  lib,
  stdenv,
  fetchFromGitHub,
  libxcrypt,
  symlinkJoin,
}:

let
  version = "3.18";
  srcAll = fetchFromGitHub {
    hash = "sha256-7zDknn2UUR2Dt3BUJ9YI0LAjRedVyUPJAiIBiRyyphQ=";
    owner = "WiringPi";
    repo = "WiringPi";
    tag = version;
  };
  mkSubProject =
    {
      subprj, # The only mandatory argument
      buildInputs ? [ ],
      src ? srcAll,
    }:
    stdenv.mkDerivation (finalAttrs: {
      inherit version src;
      inherit buildInputs;
      pname = "wiringpi-${subprj}";

      makeFlags = [
        "DESTDIR=${placeholder "out"}"
        "PREFIX=/."
        # On NixOS we don't need to run ldconfig during build:
        "LDCONFIG=echo"
      ];

      # Fix build with gcc 15
      env.NIX_CFLAGS_COMPILE = "-std=gnu17";

      # Remove (meant for other OSs) lines from Makefiles
      preInstall = ''
        sed -i "/chown root/d" Makefile
        sed -i "/chmod/d" Makefile
      '';

      sourceRoot = "${src.name}/${subprj}";
    });
  passthru = {
    inherit mkSubProject;
    # Helps nix-update and probably nixpkgs-update find the src of this package
    # automatically.
    src = srcAll;

    devLib = mkSubProject {
      buildInputs = [ passthru.wiringPi ];
      subprj = "devLib";
    };

    gpio = mkSubProject {
      buildInputs = [
        libxcrypt
        passthru.wiringPi
        passthru.devLib
      ];

      subprj = "gpio";
    };

    wiringPi = mkSubProject {
      buildInputs = [ libxcrypt ];
      subprj = "wiringPi";
    };

    wiringPiD = mkSubProject {
      buildInputs = [
        libxcrypt
        passthru.wiringPi
        passthru.devLib
      ];

      subprj = "wiringPiD";
    };
  };
in

symlinkJoin {
  inherit passthru version;
  pname = "wiringpi";

  paths = [
    passthru.wiringPi
    passthru.devLib
    passthru.wiringPiD
    passthru.gpio
  ];

  meta = {
    description = "Gordon's Arduino wiring-like WiringPi Library for the Raspberry Pi (Unofficial Mirror for WiringPi bindings)";
    homepage = "https://github.com/WiringPi/WiringPi";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      doronbehar
      ryand56
    ];

    platforms = lib.platforms.linux;
  };
}
