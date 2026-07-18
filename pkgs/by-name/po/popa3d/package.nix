{
  lib,
  stdenv,
  fetchurl,
  libxcrypt,
  openssl,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "popa3d";
  version = "1.0.3";

  src = fetchurl {
    url = "https://www.openwall.com/popa3d/popa3d-${finalAttrs.version}.tar.gz";
    hash = "sha256-A7hT2vnyQm/RjUENM76C7zofCcFQ0spNIhRiTU5jiLw=";
  };

  patches = [
    ./fix-mail-spool-path.patch
    ./use-openssl.patch
    ./use-glibc-crypt.patch
    ./enable-standalone-mode.patch
    ./fix-gcc15.patch
  ];

  buildInputs = [
    openssl
    libxcrypt
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "MANDIR=$(out)/share/man"
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  enableParallelBuilding = true;
  versionCheckProgramArg = "-V";

  meta = {
    description = "Tiny POP3 daemon with security as the primary goal";
    homepage = "http://www.openwall.com/popa3d/";
    platforms = lib.platforms.linux;
    mainProgram = "popa3d";
  };
})
