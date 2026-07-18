{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  nasm,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "davs2";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "pkuvcl";
    repo = "davs2";
    tag = finalAttrs.version;
    hash = "sha256-SUY3arrVsFecMcbpmQP0+4rtcSRfQc6pzxZDcEuMWPU=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  postPatch = ''
    substituteInPlace ./version.sh \
      --replace-fail "date" 'date -ud "@$SOURCE_DATE_EPOCH"'
  '';

  nativeBuildInputs = [
    nasm
  ];

  configureFlags = [
    "--cross-prefix=${stdenv.cc.targetPrefix}"
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isStatic) [
    (lib.enableFeature true "shared")
    "--system-libdavs2"
  ];

  preConfigure = ''
    # Generate version.h
    ./version.sh
    cd build/linux

    # We need to explicitly set AS to nasm on x86, because the assembly code uses NASM-isms,
    # and to empty string on all other platforms, because the build system erroneously assumes
    # that assembly code exists for non-x86 platforms, and will not attempt to build it
    # if AS is explicitly set to empty.
    export AS=${if stdenv.hostPlatform.isx86 then "nasm" else ""}
  '';

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules { package = finalAttrs.finalPackage; };
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Open-source decoder of AVS2-P2/IEEE1857.4 video coding standard";
    homepage = "https://github.com/pkuvcl/davs2";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    platforms = lib.platforms.all;
    mainProgram = "davs2";
    pkgConfigModules = [ "davs2" ];
  };
})
