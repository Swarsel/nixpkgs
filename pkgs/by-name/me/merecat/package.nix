{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libconfuse,
  libxcrypt,
  merecat,
  nixosTests,
  pkg-config,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "merecat";
  version = "2.31";

  # Or, already reconf'd: ftp://ftp.troglobit.com/merecat/merecat-${finalAttrs.version}.tar.xz
  src = fetchFromGitHub {
    owner = "troglobit";
    repo = "merecat";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oIzOXUnCFqd3HPyKp58r+enRRpaE7f9hqNITtxCCB7I=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libconfuse
    libxcrypt
  ];

  passthru.tests = {
    inherit (nixosTests) merecat;

    testVersion = testers.testVersion {
      command = "merecat -V";
      package = merecat;
    };
  };

  meta = {
    description = "Small and made-easy HTTP/HTTPS server based on Jef Poskanzer's thttpd";
    homepage = "https://troglobit.com/projects/merecat/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
    # Strange header and/or linker errors
    broken = stdenv.hostPlatform.isDarwin;
  };
})
