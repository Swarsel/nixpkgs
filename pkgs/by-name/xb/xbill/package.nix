{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  copyDesktopItems,
  fetchpatch,
  imagemagick,
  libx11,
  libxpm,
  libxt,
  makeDesktopItem,
  motif,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xbill";
  version = "2.1";

  src = fetchurl {
    url = "http://www.xbill.org/download/xbill-${finalAttrs.version}.tar.gz";
    hash = "sha256-Dv3/8c4t9wt6FWActIjNey65GNIdeOh3vXc/ESlFYI0=";
  };

  # xbill requires strcasecmp and strncasecmp but is missing proper includes
  patches = [
    (fetchpatch {
      hash = "sha256-Eg8qbSOdUoENcYruH6hSVIHcORkJeP8FXvp09cj/IXA=";
      url = "https://raw.githubusercontent.com/gentoo/gentoo/7c2c329a5a80781a9aaca24221675a0db66fd244/games-arcade/xbill/files/xbill-2.1-clang16.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook # Fix configure script that fails basic compilation check
    copyDesktopItems
    imagemagick
  ];

  buildInputs = [
    libx11
    libxpm
    libxt
    motif
  ];

  configureFlags = [
    "--with-x"
    "--enable-motif"
  ];

  makeFlags = "-B";
  env.NIX_CFLAGS_LINK = "-lXpm";

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/48x48/apps
    magick pixmaps/icon.xpm -resize 48x48 $out/share/icons/hicolor/48x48/apps/xbill.png
  '';

  doInstallCheck = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "ArcadeGame"
      ];

      comment = "Get rid of those Wingdows viruses!";
      desktopName = "XBill";
      exec = "xbill";
      icon = "xbill";
      name = "xbill";
    })
  ];

  postInstallCheck = ''
    $out/bin/xbill --version
  '';

  meta = {
    description = "Protect a computer network from getting infected";

    longDescription = ''
      Ever get the feeling that nothing is going right? You're a sysadmin,
      and someone's trying to destroy your computers. The little people
      running around the screen are trying to infect your computers with
      Wingdows [TM], a virus cleverly designed to resemble a popular
      operating system.
    '';

    homepage = "http://www.xbill.org/";
    license = lib.licenses.gpl1Only;

    maintainers = with lib.maintainers; [
      aw
      jonhermansen
    ];

    platforms = lib.platforms.unix;
    mainProgram = "xbill";
  };
})
