{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  freetype,
  ninja,
  nix-update-script,
  plutovg,
  testers,
  validatePkgConfig,
  enableFreetype ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "plutosvg";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "plutosvg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+Fo1B9jH/jjcSkrW5Hm6giIYm7zYh7puFFhC6er7XIM=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # https://github.com/sammycage/plutosvg/pull/29
    ./0001-Emit-correct-pkg-config-file-if-paths-are-absolute.patch
  ];

  nativeBuildInputs = [
    cmake
    ninja
    validatePkgConfig
  ];

  propagatedBuildInputs = [
    plutovg
  ]
  ++ lib.optional enableFreetype freetype;

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "PLUTOSVG_ENABLE_FREETYPE" enableFreetype)
  ];

  passthru.tests = {
    cmake-config = testers.hasCmakeConfigModules {
      moduleNames = [ "plutosvg" ];
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };

    pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tiny SVG rendering library in C";
    homepage = "https://github.com/sammycage/plutosvg";
    changelog = "https://github.com/sammycage/plutosvg/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marcin-serwin ];
    pkgConfigModules = [ "plutosvg" ];
  };
})
