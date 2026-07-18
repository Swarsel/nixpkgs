{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ctestCheckHook,
  double-conversion,
  fizz,
  folly,
  gflags,
  glog,
  gtest,
  libevent,
  ninja,
  nix-update-script,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wangle";
  version = "2026.01.19.00";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "wangle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tGq6jbBPotuBK1PuRRGvdNb208glzlt7dehjIY+4nvk=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./glog-0.7.patch
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    folly
    fizz
    openssl
    glog
    gflags
    libevent
    double-conversion
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))

    (lib.cmakeBool "BUILD_TESTS" finalAttrs.finalPackage.doCheck)

    (lib.cmakeFeature "INCLUDE_INSTALL_DIR" "${placeholder "dev"}/include")
    (lib.cmakeFeature "LIB_INSTALL_DIR" "${placeholder "out"}/lib")
    (lib.cmakeFeature "CMAKE_INSTALL_DIR" "${placeholder "dev"}/lib/cmake/wangle")
  ];

  doCheck = true;

  nativeCheckInputs = [
    ctestCheckHook
  ];

  checkInputs = [
    gtest
  ];

  __darwinAllowLocalNetworking = true;
  cmakeDir = "../wangle";

  disabledTests = [
    # Deterministic glibc abort 🫠
    "BootstrapTest"
    "BroadcastPoolTest"

    # SSLContextManagerTest uses 15+ GB of RAM
    "SSLContextManagerTest"
  ];

  dontUseNinjaCheck = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source C++ networking library";

    longDescription = ''
      Wangle is a framework providing a set of common client/server
      abstractions for building services in a consistent, modular, and
      composable way.
    '';

    homepage = "https://github.com/facebook/wangle";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      pierreis
      kylesferrazza
      emily
      techknowlogick
      lf-
    ];

    platforms = lib.platforms.unix;
  };
})
