{
  lib,
  stdenv,
  cmake,
  fetchgit,
  gitUpdater,
  ninja,
  perl,
  withShared ? !stdenv.hostPlatform.isStatic,
}:

# reference: https://boringssl.googlesource.com/boringssl/+/refs/tags/0.20250818.0/BUILDING.md
stdenv.mkDerivation (finalAttrs: {
  pname = "boringssl";
  version = "0.20260526.0";

  src = fetchgit {
    url = "https://boringssl.googlesource.com/boringssl";
    tag = finalAttrs.version;
    hash = "sha256-SmyImyzGn7v2b5qGJbMmQZX5bODA9i6+8jy3uGwOawA=";
  };

  outputs = [
    "out"
    "bin"
    "dev"
  ];

  patches = [
    # Add SECP224R1 for backward compatibility
    ./secp224r1-compat.patch
  ];

  nativeBuildInputs = [
    cmake
    ninja
    perl
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" withShared)
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isGNU [
      # Needed with GCC 12 but breaks on darwin (with clang)
      "-Wno-error=stringop-overflow"
      "-Wno-error=array-bounds"
    ]
    ++ lib.optionals stdenv.cc.isClang [
      "-Wno-error=character-conversion"
    ]
  );

  passthru = {
    isShared = withShared;
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Free TLS/SSL implementation";
    homepage = "https://boringssl.googlesource.com";

    license = with lib.licenses; [
      asl20
      isc
      mit
      bsd3
    ];

    maintainers = with lib.maintainers; [
      thoughtpolice
      theoparis
      niklaskorz
    ];

    mainProgram = "bssl";
  };
})
