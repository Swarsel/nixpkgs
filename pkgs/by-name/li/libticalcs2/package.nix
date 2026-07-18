{
  lib,
  stdenv,
  fetchurl,
  acl,
  autoreconfHook,
  bzip2,
  glib,
  libticables2,
  libticonv,
  libtifiles2,
  pkg-config,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libticalcs2";
  version = "1.1.9";

  src = fetchurl {
    url = "mirror://sourceforge/tilp/libticalcs2-${finalAttrs.version}.tar.bz2";
    sha256 = "08c9wgrdnyqcs45mx1bjb8riqq81bzfkhgaijxzn96rhpj40fy3n";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    glib
    libticonv
    libtifiles2
    libticables2
    xz
    bzip2
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    acl
  ];

  meta = {
    description = "This library is part of the TiLP framework";
    homepage = "http://lpg.ticalc.org/prj_tilp/";
    changelog = "http://lpg.ticalc.org/prj_tilp/news.html";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = with lib.platforms; linux ++ darwin;
  };
})
