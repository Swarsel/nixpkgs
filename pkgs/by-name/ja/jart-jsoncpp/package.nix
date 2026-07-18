{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyPkgconfigItems,
  ctestCheckHook,
  double-conversion,
  makePkgconfigItem,
  ninja,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "json.cpp";
  version = "0-unstable-2025-10-25";

  src = fetchFromGitHub {
    owner = "jart";
    repo = "json.cpp";
    rev = "6ec4e44a5bbaadbe677473378c3d2133644c58a1";
    hash = "sha256-kUFtyFPoHGCFWTGRD8SoBsqHYCplGPw/AcpMR9T0Ffk=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    copyPkgconfigItems
    ctestCheckHook
    ninja
  ];

  buildInputs = [
    double-conversion
  ];

  cmakeFlags = [
    (lib.cmakeBool "JSON_CPP_BUILD_TESTS" true)
    (lib.cmakeBool "DOUBLE_CONVERSION_VENDORED" false)
    (lib.cmakeBool "BUILD_SHARED_LIBS" stdenv.hostPlatform.hasSharedLibraries)
  ];

  doCheck = true;

  # https://github.com/jart/json.cpp/issues/17
  pkgconfigItems = [
    (makePkgconfigItem rec {
      inherit (finalAttrs) version;
      inherit (finalAttrs.meta) description;
      cflags = [ "-I${variables.includedir}" ];

      libs = [
        "-L${variables.libdir}"
        "-ljson"
      ];

      libsPrivate = [
        # nixpkgs double-conversion does not support pkg-config
        # as of yet.
        "-ldouble-conversion"
      ];

      name = "json.cpp";

      variables = {
        includedir = "${placeholder "dev"}/include";
        libdir = "${placeholder "out"}/lib";
      };
    })
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  meta = {
    description = "JSON for Classic C++";
    homepage = "https://github.com/jart/json.cpp";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fzakaria ];
    pkgConfigModules = [ "json.cpp" ];
  };
})
