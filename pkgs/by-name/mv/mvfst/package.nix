{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ctestCheckHook,
  fizz,
  folly,
  gflags,
  glog,
  gtest,
  ninja,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mvfst";
  version = "2026.01.19.00";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "mvfst";
    tag = "v${finalAttrs.version}";
    hash = "sha256-K4rskeF66EHchsBj8wIP3BYBa7SvQ1ohnOV0HPu+y80=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
  ];

  patches = [
    ./glog-0.7.patch
  ];

  postPatch = ''
    # Make sure the libraries the `tperf` binary uses are installed.
    printf 'install(TARGETS mvfst_test_utils)\n' >> quic/common/test/CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    folly
    gflags
    glog
  ];

  propagatedBuildInputs = [
    fizz
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))

    (lib.cmakeBool "CMAKE_INSTALL_RPATH_USE_LINK_PATH" true)

    (lib.cmakeBool "BUILD_TESTS" finalAttrs.finalPackage.doCheck)

    (lib.cmakeFeature "CMAKE_INSTALL_PREFIX" (placeholder "dev"))
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Homebrew sets this, and the shared library build fails without
    # it. I don‘t know, either. It scares me.
    (lib.cmakeFeature "CMAKE_SHARED_LINKER_FLAGS" "-Wl,-undefined,dynamic_lookup")
  ];

  doCheck = true;

  nativeCheckInputs = [
    ctestCheckHook
  ];

  checkInputs = [
    gtest
  ];

  __darwinAllowLocalNetworking = true;

  disabledTests = [
    "*/QuicClientTransportIntegrationTest.NetworkTest/*"
    "*/QuicClientTransportIntegrationTest.FlowControlLimitedTest/*"
    "*/QuicClientTransportIntegrationTest.NetworkTestConnected/*"
    "*/QuicClientTransportIntegrationTest.SetTransportSettingsAfterStart/*"
    "*/QuicClientTransportIntegrationTest.TestZeroRttSuccess/*"
    "*/QuicClientTransportIntegrationTest.ZeroRttRetryPacketTest/*"
    "*/QuicClientTransportIntegrationTest.NewTokenReceived/*"
    "*/QuicClientTransportIntegrationTest.UseNewTokenThenReceiveRetryToken/*"
    "*/QuicClientTransportIntegrationTest.TestZeroRttRejection/*"
    "*/QuicClientTransportIntegrationTest.TestZeroRttNotAttempted/*"
    "*/QuicClientTransportIntegrationTest.TestZeroRttInvalidAppParams/*"
    "*/QuicClientTransportIntegrationTest.ChangeEventBase/*"
    "*/QuicClientTransportIntegrationTest.ResetClient/*"
    "*/QuicClientTransportIntegrationTest.TestStatelessResetToken/*"
  ];

  dontUseNinjaCheck = true;

  hardeningDisable = [
    # causes test failures on aarch64
    "pacret"
    # causes empty cmake files to be generated
    "trivialautovarinit"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Implementation of the QUIC transport protocol";
    homepage = "https://github.com/facebook/mvfst";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ris
      emily
      techknowlogick
      lf-
    ];

    platforms = lib.platforms.unix;
  };
})
