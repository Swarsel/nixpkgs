{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  cmake,
  libtomcrypt,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stormlib";
  version = "9.30";

  src = fetchFromGitHub {
    owner = "ladislav-zezula";
    repo = "StormLib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gW3jR9XnBo5uEORu12TpGsUMFAS4w5snWPA/bIUt9UY=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "FRAMEWORK DESTINATION /Library/Frameworks" "FRAMEWORK DESTINATION Library/Frameworks"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    bzip2
    libtomcrypt
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "WITH_LIBTOMCRYPT" true)
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isClang [
      "-Wno-implicit-function-declaration"
      "-Wno-int-conversion"
    ]
  );

  meta = {
    description = "Open-source project that can work with Blizzard MPQ archives";
    homepage = "https://github.com/ladislav-zezula/StormLib";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aanderse
    ];

    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin; # installation directory mismatch
  };
})
