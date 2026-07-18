{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  versionCheckHook,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "otf2";
  version = "3.2";

  src = fetchurl {
    url = "https://perftools.pages.jsc.fz-juelich.de/cicd/otf2/tags/otf2-${finalAttrs.version}/otf2-${finalAttrs.version}.tar.gz";
    hash = "sha256-grOoilUMuMPOyP1F7Kgs3Lr5RSCZd0gkcbS15DDWSo0=";
  };

  outputs = [
    "out"
    "lib"
    "doc"
  ];

  postPatch = ''
    substituteInPlace build-config/common/platforms/platform-backend-user-provided \
      --replace-fail 'CC=' 'CC=${stdenv.cc.targetPrefix}cc' \
      --replace-fail 'CXX=' 'CXX=${stdenv.cc.targetPrefix}c++'
    substituteInPlace build-config/common/platforms/platform-frontend-user-provided \
      --replace-fail 'CC_FOR_BUILD=' 'CC_FOR_BUILD=${buildPackages.stdenv.cc.targetPrefix}cc' \
      --replace-fail 'CXX_FOR_BUILD=' 'CXX_FOR_BUILD=${buildPackages.stdenv.cc.targetPrefix}c++'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    which # used in configure script
  ];

  configureFlags = [
    (lib.enableFeature finalAttrs.finalPackage.doCheck "backend-test-runs")
    (lib.withFeature true "custom-compilers")
  ]
  ++ lib.optionals (!lib.systems.equals stdenv.buildPlatform stdenv.hostPlatform) [
    "ac_scorep_cross_compiling=yes"
  ];

  doCheck = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;
  enableParallelChecking = true;
  versionCheckProgram = [ "${placeholder "out"}/bin/otf2-config" ];

  meta = {
    description = "Open Trace Format 2 library";
    homepage = "https://www.vi-hps.org/projects/score-p";
    changelog = "https://perftools.pages.jsc.fz-juelich.de/cicd/otf2/tags/otf2-${finalAttrs.version}/ChangeLog.txt";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ lesuisse ];
  };
})
