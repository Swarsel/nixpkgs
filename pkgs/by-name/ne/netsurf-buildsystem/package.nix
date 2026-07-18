{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "netsurf-buildsystem";
  version = "1.10";

  src = fetchurl {
    url = "https://download.netsurf-browser.org/libs/releases/buildsystem-${finalAttrs.version}.tar.gz";
    hash = "sha256-PT451WnkRnfEsXkSm95hTGV5jis+YlMWAjnR/W6uTXk=";
  };

  makeFlags = [
    "PREFIX=$(out)"
  ];

  meta = {
    description = "NetSurf browser shared build system";
    homepage = "https://www.netsurf-browser.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.unix;
  };
})
