{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  nlohmann_json,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vvenc";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "fraunhoferhhi";
    repo = "vvenc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MZVXxUXpcZ16de3CZDscLOlnqjHkGZ98muhYCDCcgvs=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  patches = [ ./unset-darwin-cmake-flags.patch ];
  nativeBuildInputs = [ cmake ];
  buildInputs = [ nlohmann_json ];

  cmakeFlags = [
    (lib.cmakeBool "VVENC_INSTALL_FULLFEATURE_APP" true)
    (lib.cmakeBool "VVENC_ENABLE_THIRDPARTY_JSON" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isGNU [
      "-Wno-maybe-uninitialized"
      "-Wno-uninitialized"
    ]
  );

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = gitUpdater {
      ignoredVersions = "rc";
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Fraunhofer Versatile Video Encoder";
    homepage = "https://github.com/fraunhoferhhi/vvenc";
    license = lib.licenses.bsd3Clear;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    platforms = lib.platforms.all;
    mainProgram = "vvencapp";
    pkgConfigModules = [ "libvvenc" ];
  };
})
