{
  lib,
  stdenv,
  fetchurl,
  db,
  gd,
  geoip,
  libpng,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "webalizer";
  version = "2.23.08";

  src = fetchurl {
    url = "mirror://debian/pool/main/w/webalizer/webalizer_${finalAttrs.version}.orig.tar.gz";
    sha256 = "sha256-7a3bWqQcxKCBoVAOP6lmFdS0G8Eghrzt+ZOAGM557Y0=";
  };

  buildInputs = [
    zlib
    libpng
    gd
    geoip
    db
  ];

  configureFlags = [
    "--enable-dns"
    "--enable-geoip"
    "--enable-shared"
  ];

  # Workaround build failure on -fno-common toolchains:
  #   ld: dns_resolv.o:(.bss+0x20): multiple definition of `system_info'; webalizer.o:(.bss+0x76e0): first defined here
  env.NIX_CFLAGS_COMPILE = "-fcommon";

  preConfigure = ''
    substituteInPlace ./configure \
      --replace "--static" ""
  '';

  installFlags = [ "MANDIR=\${out}/share/man/man1" ];

  meta = {
    description = "Web server log file analysis program";
    homepage = "https://webalizer.net/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
})
