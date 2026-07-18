{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  libx11,
  makeDesktopItem,
  ncurses,
}:

let
  pname = "tome2";
  description = "Dungeon crawler similar to Angband, based on the works of Tolkien";

  desktopItem = makeDesktopItem {
    categories = [
      "Game"
      "RolePlaying"
    ];

    comment = description;
    desktopName = pname;
    exec = "${pname}-x11";
    genericName = pname;
    icon = pname;
    name = pname;
    type = "Application";
  };

in
stdenv.mkDerivation {
  inherit pname;
  version = "2.4-unstable-2025-02-17";

  src = fetchFromGitHub {
    owner = "tome2";
    repo = "tome2";
    rev = "3892fbcb1c2446afcb0c34f59e2a24f78ae672c4";
    hash = "sha256-OL59zktCJGBHPE8Y89S+OdcnJ/Hj+dGif1DNhePEQXo=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    ncurses
    libx11
    boost
  ];

  cmakeFlags = [
    "-DSYSTEM_INSTALL=ON"
  ];

  postInstall = ''
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/*.desktop $out/share/applications
  '';

  meta = {
    inherit description;
    homepage = "https://github.com/tome2/tome2";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ cizra ];
    platforms = lib.platforms.all;
  };
}
