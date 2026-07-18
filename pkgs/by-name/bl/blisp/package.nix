{
  lib,
  stdenv,
  fetchFromGitHub,
  argtable,
  cmake,
  libserialport,
  pkg-config,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "blisp";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "pine64";
    repo = "blisp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qjZ5BNQR57J78Y6MT9I388OCLOiYTevPJ2btgmtkpJw=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    argtable
    libserialport
  ];

  cmakeFlags = [
    "-DBLISP_BUILD_CLI=ON"
    "-DBLISP_USE_SYSTEM_LIBRARIES=ON"
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-Wno-error=implicit-function-declaration";

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "In-System-Programming (ISP) tool & library for Bouffalo Labs RISC-V Microcontrollers and SoCs";
    homepage = "https://github.com/pine64/blisp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bdd ];
    platforms = lib.platforms.unix;
    mainProgram = "blisp";
  };
})
