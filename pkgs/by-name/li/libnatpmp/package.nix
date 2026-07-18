{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  fixDarwinDylibNames,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnatpmp";
  version = "20230423";

  src = fetchurl {
    url = "https://miniupnp.tuxfamily.org/files/libnatpmp-${finalAttrs.version}.tar.gz";
    hash = "sha256-BoTtLIQGQ351GaG9IOqDeA24cbOjpddSMRuj6Inb/HA=";
  };

  patches = [
    # install natpmp_declspec.h too, else nothing that uses this library will build
    (fetchpatch {
      hash = "sha256-tvoGFmo5AzUgb40bIs/EzikE0ex1SFzE5peLXhktnbc=";
      url = "https://github.com/miniupnp/libnatpmp/commit/5f4a7c65837a56e62c133db33c28cd1ea71db662.patch";
    })
  ];

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  makeFlags = [
    "INSTALLPREFIX=$(out)"
    "CC:=$(CC)"
  ];

  postFixup = ''
    chmod +x $out/lib/*
  '';

  meta = {
    description = "NAT-PMP client";
    homepage = "http://miniupnp.free.fr/libnatpmp.html";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "natpmpc";
  };
})
