{
  lib,
  stdenv,
  fetchFromGitHub,
  avrgcc,
  avrlibc,
  libGL,
  libGLU,
  libelf,
  libglut,
  makeSetupHook,
  pkg-config,
  which,
}:

let
  setupHookDarwin = makeSetupHook {
    name = "darwin-avr-gcc-hook";

    substitutions = {
      avrSuffixSalt = avrgcc.suffixSalt;
      darwinSuffixSalt = stdenv.cc.suffixSalt;
    };

    meta.license = lib.licenses.mit;
  } ./setup-hook-darwin.sh;

in
stdenv.mkDerivation rec {
  pname = "simavr";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "buserror";
    repo = "simavr";
    rev = "v${version}";
    sha256 = "0njz03lkw5374x1lxrq08irz4b86lzj2hibx46ssp7zv712pq55q";
  };

  nativeBuildInputs = [
    which
    pkg-config
    avrgcc
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin setupHookDarwin;

  buildInputs = [
    libelf
    libglut
    libGLU
    libGL
  ];

  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
    "AVR_ROOT=${avrlibc}/avr"
    "SIMAVR_VERSION=${version}"
    "AVR=avr-"
  ];

  doCheck = true;

  # remove forbidden references to $TMPDIR
  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" "$out"/bin/*
  '';

  checkTarget = "-C tests run_tests";

  meta = {
    description = "Lean and mean Atmel AVR simulator";
    homepage = "https://github.com/buserror/simavr";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      goodrone
      patryk27
    ];

    platforms = lib.platforms.unix;
    mainProgram = "simavr";
  };
}
