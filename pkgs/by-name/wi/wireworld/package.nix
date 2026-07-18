{
  lib,
  stdenv,
  fetchFromGitLab,
  copyDesktopItems,
  love,
  makeDesktopItem,
  makeWrapper,
  strip-nondeterminism,
  zip,
}:

stdenv.mkDerivation {
  pname = "wireworld";
  version = "unstable-2023-05-09";

  src = fetchFromGitLab {
    owner = "blinry";
    repo = "wireworld";
    rev = "03b82bf5d604d6d4ad3c07b224583de6c396fd17";
    hash = "sha256-8BshnGLuA8lmG9g7FU349DWKP/fZvlvjrQBau/LSJ4E=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    strip-nondeterminism
    zip
  ];

  installPhase = ''
    runHook preInstall
    zip -9 -r Wireworld.love ./*
    strip-nondeterminism --type zip Wireworld.love
    install -Dm444 -t $out/share/games/lovegames/ Wireworld.love
    makeWrapper ${love}/bin/love $out/bin/Wireworld \
      --add-flags $out/share/games/lovegames/Wireworld.love
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "";
      desktopName = "Wireworld";
      exec = "Wireworld";
      genericName = "Wireworld";
      name = "Wireworld";
    })
  ];

  meta = {
    description = "Fascinating electronics logic puzzles, game where you'll learn how to build clocks, diodes, and logic gates";
    homepage = "https://gitlab.com/blinry/wireworld";

    license = with lib.licenses; [
      mit
      ofl
      blueOak100
      cc-by-sa-30
      cc-by-sa-40
    ];

    maintainers = [ ];
    mainProgram = "Wireworld";
    downloadPage = "https://ldjam.com/events/ludum-dare/53/wireworld";
  };

}
