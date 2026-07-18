{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  SDL2_net,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "maelstrom";
  version = "3.0.7";

  src = fetchurl {
    url = "https://www.libsdl.org/projects/Maelstrom/src/Maelstrom-${finalAttrs.version}.tar.gz";
    sha256 = "0dm0m5wd7amrsa8wnrblkv34sq4v4lglc2wfx8klfkdhyhi06s4k";
  };

  patches = [
    # this fixes a typedef compilation error with gcc-3.x
    ./fix-compilation.patch
    # removes register keyword
    ./c++17-fixes.diff
    # fix build with gcc14
    ./add-maelstrom-netd-include-time.diff
  ];

  buildInputs = [
    SDL2
    SDL2_net
  ];

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/games/Maelstrom/Maelstrom $out/bin/maelstrom
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "An arcade-style game resembling Asteroids";
      desktopName = "Maelstrom";
      exec = "maelstrom";
      genericName = "Maelstrom";
      name = "maelstrom";
    })
  ];

  meta = {
    description = "Arcade-style game resembling Asteroids";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ tmountain ];
    platforms = lib.platforms.all;
    mainProgram = "maelstrom";
  };
})
