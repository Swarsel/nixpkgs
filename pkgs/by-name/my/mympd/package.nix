{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  flac,
  gzip,
  jq,
  libid3tag,
  libmpdclient,
  lua5_3,
  nixosTests,
  openssl,
  pcre2,
  perl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mympd";
  version = "25.3.0";

  src = fetchFromGitHub {
    owner = "jcorporation";
    repo = "myMPD";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Mx+UURIJUpIZlLq0FFuvOoUzMHhHryfNxRpNWgrpHTM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    cmake
    gzip
    perl
    jq
    lua5_3 # luac is needed for cross builds
  ];

  buildInputs = [
    libmpdclient
    openssl
    lua5_3
    libid3tag
    flac
    pcre2
  ];

  cmakeFlags = [
    # Otherwise, it tries to parse $out/etc/mympd.conf on startup.
    "-DCMAKE_INSTALL_SYSCONFDIR=/etc"
    # similarly here
    "-DCMAKE_INSTALL_LOCALSTATEDIR=/var/lib/mympd"
  ];

  preConfigure = ''
    env MYMPD_BUILDDIR=$PWD/build ./build.sh createassets
  '';

  # 5 tests out of 23 fail, probably due to the sandbox...
  doCheck = false;

  hardeningDisable = [
    # causes redefinition of _FORTIFY_SOURCE
    "fortify3"
  ];

  passthru.tests = { inherit (nixosTests) mympd; };

  meta = {
    description = "Standalone and mobile friendly web mpd client with a tiny footprint and advanced features";
    homepage = "https://jcorporation.github.io/myMPD";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.doronbehar ];
    platforms = lib.platforms.linux;
    mainProgram = "mympd";
  };
})
