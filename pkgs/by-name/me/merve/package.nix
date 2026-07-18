{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  nix-update-script,
  simdutf,
  testers,
  validatePkgConfig,
  static ? stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "merve";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "nodejs";
    repo = "merve";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CrdQNAAUbV9k15IFEQjYiMpwbj3iE7imjnN6HloTk40=";
  };

  nativeBuildInputs = [
    cmake
    validatePkgConfig
  ];

  buildInputs = [
    simdutf
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!static))
    (lib.cmakeBool "MERVE_TESTING" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "MERVE_USE_SIMDUTF" true)
  ];

  doCheck = true;

  checkInputs = [
    gtest
  ];

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Lexer to extract named exports via analysis from CommonJS modules";
    homepage = "https://github.com/nodejs/merve";
    changelog = "https://github.com/nodejs/merve/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aduh95 ];
    platforms = lib.platforms.all;
    pkgConfigModules = [ "merve" ];
  };
})
