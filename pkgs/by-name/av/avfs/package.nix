{
  lib,
  stdenv,
  fetchurl,
  fuse3,
  pkg-config,
  xz,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "avfs";
  version = "1.3.0";

  src = fetchurl {
    url = "mirror://sourceforge/avf/${finalAttrs.version}/avfs-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-B81p1MDH7QgOgP8EDZgChkBa04pEP9xS3Dle/vEcRLE=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fuse3
    xz
    zlib
  ];

  configureFlags = [
    "--enable-library"
    "--enable-fuse"
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin "--with-system-zlib";

  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-function-pointer-types";
  };

  meta = {
    description = "Virtual filesystem that allows browsing of compressed files";
    homepage = "https://avf.sourceforge.net/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ tbutter ];
    platforms = lib.platforms.unix;
  };
})
