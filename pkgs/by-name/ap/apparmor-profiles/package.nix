{
  lib,
  stdenv,
  apparmor-parser,
  apparmor-utils,
  callPackage,
  # apparmor deps
  libapparmor,
  python3,
  which,
}:
stdenv.mkDerivation {
  inherit (libapparmor) version src;
  pname = "apparmor-profiles";
  strictDeps = true;
  nativeBuildInputs = [ which ];
  doCheck = true;

  nativeCheckInputs = [
    apparmor-parser
    apparmor-utils
  ];

  checkInputs = [
    python3
  ];

  preCheck = ''
    export USE_SYSTEM=1
    export LOGPROF="aa-logprof --configdir ${callPackage ./test_config.nix { }} --no-check-mountpoint"
    patchShebangs ../parser/tst
    substituteInPlace ../parser/tst/test_profile.py \
      --replace-fail '../parser/apparmor_parser' '${lib.getExe apparmor-parser}'
  '';

  checkTarget = "check";

  installFlags = [
    "DESTDIR=$(out)"
    "EXTRAS_DEST=$(out)/share/apparmor/extra-profiles"
  ];

  sourceRoot = "${libapparmor.src.name}/profiles";

  meta = libapparmor.meta // {
    description = "Mandatory access control system - profiles";
    mainProgram = "apparmor_parser";
  };
}
