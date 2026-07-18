{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  testers,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "quickjs-ng";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "quickjs-ng";
    repo = "quickjs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kQDaDCljI+NcElufZZAmSGMbI2wyiQC6Lp4CyHW0aBY=";
  };

  outputs = [
    "out"
    "bin"
    "dev"
    "doc"
    "info"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    texinfo
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "BUILD_STATIC_QJS_EXE" stdenv.hostPlatform.isStatic)
  ];

  postBuild = ''
    pushd ../docs
    makeinfo *texi
    popd
  '';

  postInstall = ''
    pushd ../docs
    install -Dm644 -t ''${!outputInfo}/share/info *info
    popd
  '';

  passthru.tests = {
    version = testers.testVersion {
      command = "qjs --help || true";
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Mighty JavaScript engine";
    homepage = "https://github.com/quickjs-ng/quickjs";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "qjs";
  };
})
