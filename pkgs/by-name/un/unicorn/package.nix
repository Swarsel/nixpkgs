{
  lib,
  stdenv,
  fetchFromGitHub,
  cctools,
  cmake,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "unicorn";
  version = "2.1.4";

  src = fetchFromGitHub {
    owner = "unicorn-engine";
    repo = "unicorn";
    tag = finalAttrs.version;
    hash = "sha256-jEQXjYlLUdKrKPL4XfSbixn2KWJlNG7IYQveF4jDgl4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools
  ];

  cmakeFlags = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    # Some x86 tests are interrupted by signal 10
    "-DCMAKE_CTEST_ARGUMENTS=--exclude-regex;test_x86"
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isRiscV {
    # Ensure the linker is using atomic when compiling for RISC-V, otherwise fails
    NIX_LDFLAGS = "-latomic";
  };

  doCheck = true;

  meta = {
    description = "Lightweight multi-platform CPU emulator library";
    homepage = "https://www.unicorn-engine.org";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      thoughtpolice
    ];

    platforms = lib.platforms.unix;
  };
})
