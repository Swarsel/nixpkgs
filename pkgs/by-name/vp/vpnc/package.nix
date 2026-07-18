{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  buildPackages,
  gnutls,
  libgcrypt,
  makeWrapper,
  openssl, # Distributing this is a GPL violation.
  perl,
  pkg-config,
  vpnc-scripts,
  opensslSupport ? false,
}:

stdenv.mkDerivation {
  pname = "vpnc";
  version = "0-unstable-2025-06-16";

  src = fetchFromGitHub {
    owner = "streambinder";
    repo = "vpnc";
    rev = "6a70db13f6e9201101e1c4890393566be6000e6a";
    sha256 = "sha256-8XgEoQn7hz/eU7w+jqxYUBuOpAQlc+2qTj1mcDMHK30=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src/vpnc-disconnect \
      --replace-fail /bin/sh ${lib.getExe' bash "sh"}
    patchShebangs src/makeman.pl
  ''
  + lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    # manpage generation invokes the build vpnc, which must be emulating when cross compiling
    substituteInPlace src/makeman.pl --replace-fail \
      '$vpnc --long-help' \
      '${stdenv.hostPlatform.emulator buildPackages} $vpnc --long-help'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    perl
  ]
  ++ lib.optional (!opensslSupport) pkg-config;

  buildInputs = [
    libgcrypt
    perl
  ]
  ++ (if opensslSupport then [ openssl ] else [ gnutls ]);

  makeFlags = [
    "PREFIX=$(out)"
    "ETCDIR=$(out)/etc/vpnc"
    "SCRIPT_PATH=${vpnc-scripts}/bin/vpnc-script"
  ]
  ++ lib.optional opensslSupport "OPENSSL_GPL_VIOLATION=yes";

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";
  };

  enableParallelBuilding = true;
  # Missing install depends:
  #   install: target '...-vpnc-unstable-2021-11-04/share/doc/vpnc': No such file or directory
  #   make: *** [Makefile:149: install-doc] Error 1
  enableParallelInstalling = false;

  meta = {
    description = "Virtual private network (VPN) client for Cisco's VPN concentrators";
    homepage = "https://davidepucci.it/doc/vpnc/";
    license = if opensslSupport then lib.licenses.unfree else lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
