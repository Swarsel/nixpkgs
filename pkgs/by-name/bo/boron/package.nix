{
  lib,
  stdenv,
  fetchurl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "boron";
  version = "2.1.0";

  src = fetchurl {
    url = "https://sourceforge.net/projects/urlan/files/Boron/boron-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-50HKcK2hQpe9k9RIoVa/N5krTRKlW9AsGYTmHITx7Nc=";
  };

  buildInputs = [
    zlib
  ];

  configureFlags = [ "--thread" ];
  makeFlags = [ "DESTDIR=$(out)" ];

  preConfigure = ''
    patchShebangs configure
  '';

  doCheck = true;

  checkPhase = ''
    patchShebangs .
    make -C test
  '';

  # this is not a standard Autotools-like `configure` script
  dontAddPrefix = true;

  installTargets = [
    "install"
    "install-dev"
  ];

  meta = {
    description = "Scripting language and C library useful for building DSLs";
    homepage = "https://urlan.sourceforge.net/boron/";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ mausch ];
    platforms = lib.platforms.linux;
    mainProgram = "boron";
  };
})
