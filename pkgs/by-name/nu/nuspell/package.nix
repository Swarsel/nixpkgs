{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  callPackage,
  catch2_3,
  cmake,
  ctestCheckHook,
  doxygen,
  icu,
  pkg-config,
  testers,
  enableManpages ? buildPackages.pandoc.compiler.bootstrapAvailable,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nuspell";
  version = "5.1.7";

  src = fetchFromGitHub {
    owner = "nuspell";
    repo = "nuspell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CAyM3bzIP0aYNEu94I7I1qlglPx9HJSnEkgEfjNGfvc=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    doxygen
    pkg-config
  ]
  ++ lib.optional enableManpages buildPackages.pandoc;

  buildInputs = [ catch2_3 ];
  propagatedBuildInputs = [ icu ];
  cmakeFlags = lib.optional (!enableManpages) "-DBUILD_DOCS=OFF";
  doCheck = true;

  nativeCheckInputs = [
    ctestCheckHook
  ];

  passthru = {
    tests = {
      cmake = testers.hasCmakeConfigModules {
        version = finalAttrs.version;
        moduleNames = [ "Nuspell" ];
        package = finalAttrs.finalPackage;
        versionCheck = true;
      };

      pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

      wrapper = testers.testVersion {
        package = finalAttrs.finalPackage.withDicts (d: [ d.en_US ]);
      };
    };

    withDicts = callPackage ./wrapper.nix { nuspell = finalAttrs.finalPackage; };
  };

  meta = {
    description = "Free and open source C++ spell checking library";
    homepage = "https://nuspell.github.io/";
    changelog = "https://github.com/nuspell/nuspell/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.all;
    mainProgram = "nuspell";
    pkgConfigModules = [ "nuspell" ];
  };
})
