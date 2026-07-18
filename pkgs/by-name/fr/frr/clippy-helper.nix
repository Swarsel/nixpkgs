{
  lib,
  stdenv,
  # build time
  autoreconfHook,
  bison,
  elfutils,
  flex,
  frrSource,
  frrVersion,
  perl,
  pkg-config,
  python3,
}:

stdenv.mkDerivation {
  pname = "frr-clippy-helper";
  version = frrVersion;
  src = frrSource;

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    perl
    pkg-config
  ];

  buildInputs = [
    python3
  ]
  ++ lib.optionals (lib.meta.availableOn stdenv.hostPlatform elfutils) [
    elfutils
  ];

  configureFlags = [
    "--enable-clippy-only"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp lib/clippy $out/bin
  '';

  enableParallelBuilding = true;

  meta = {
    description = "FRR routing daemon suite: CLI helper tool clippy";

    longDescription = ''
      This small tool is used to support generating CLI code for FRR. It is split out here,
      to support cross-compiling, because it needs to be compiled with the build system toolchain
      and not the target host one.
    '';

    homepage = "https://frrouting.org/";

    license = with lib.licenses; [
      gpl2Plus
      lgpl21Plus
    ];

    maintainers = with lib.maintainers; [ thillux ];
    platforms = lib.platforms.unix;
  };
}
