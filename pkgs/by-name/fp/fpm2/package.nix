{
  lib,
  stdenv,
  fetchurl,
  gnupg,
  gtk3,
  intltool,
  libxml2,
  nettle,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fpm2";
  version = "0.90.1";

  src = fetchurl {
    url = "https://als.regnet.cz/fpm2/download/fpm2-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-G6PF5wlEc19jtqOxBTp/10dQiFYPDO/W6v9Oyzz1lZA=";
  };

  nativeBuildInputs = [
    pkg-config
    intltool
  ];

  buildInputs = [
    gnupg
    gtk3
    libxml2
    nettle
  ];

  meta = {
    description = "GTK2 port from Figaro's Password Manager originally developed by John Conneely, with some new enhancements";
    homepage = "https://als.regnet.cz/fpm2/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ hce ];
    platforms = lib.platforms.linux;
    mainProgram = "fpm2";
  };
})
