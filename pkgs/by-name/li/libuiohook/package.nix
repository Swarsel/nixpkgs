{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libx11,
  libxau,
  libxcb,
  libxdmcp,
  libxext,
  libxi,
  libxinerama,
  libxkbcommon,
  libxkbfile,
  libxt,
  libxtst,
  nixosTests,
  pkg-config,
  xinput,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libuiohook";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "kwhat";
    repo = "libuiohook";
    rev = finalAttrs.version;
    sha256 = "1qlz55fp4i9dd8sdwmy1m8i4i1jy1s09cpmlxzrgf7v34w72ncm7";
  };

  outputs = [
    "out"
    "test"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libx11
    libxcb
    libxkbcommon
    xinput
    libxau
    libxdmcp
    libxi
    libxinerama
    libxt
    libxtst
    libxext
    libxkbfile
  ];

  # We build the tests, but they're only installed when using the "test" output.
  # This will produce a "uiohook_tests" binary which can be run to test the
  # functionality of the library on the current system.
  # Running the test binary requires a running X11 session.
  cmakeFlags = [
    "-DENABLE_TEST:BOOL=ON"
  ];

  # Mismatched arg counts in tests break under gcc 15's C23 default.
  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-std=gnu17";
  };

  postInstall = ''
    mkdir -p $test/share
    cp ./uiohook_tests $test/share
  '';

  passthru.tests.libuiohook = nixosTests.libuiohook;

  meta = {
    description = "C library to provide global keyboard and mouse hooks from userland";
    homepage = "https://github.com/kwhat/libuiohook";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ anoa ];
    platforms = lib.platforms.all;
  };
})
