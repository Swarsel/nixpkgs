{
  lib,
  fetchFromGitLab,
  copyDesktopItems,
  love,
  makeDesktopItem,
  makeWrapper,
  stdenvNoCC,
  strip-nondeterminism,
  zip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "stone-kingdoms";
  version = "0.6.1";

  src = fetchFromGitLab {
    owner = "stone-kingdoms";
    repo = "stone-kingdoms";
    tag = version;
    hash = "sha256-W2hzJg22O857Kh7CJVVHV5qu8QKjXCwW3hmgKBc0n2g=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    strip-nondeterminism
    zip
  ];

  installPhase = ''
    runHook preInstall
    zip -9 -r stone-kingdoms.love ./*
    strip-nondeterminism --type zip stone-kingdoms.love
    install -Dm755 -t $out/share/games/lovegames/ stone-kingdoms.love
    install -Dm644 assets/other/icon.png $out/share/icons/hicolor/256x256/apps/stone-kingdoms.png
    makeWrapper ${lib.getExe love} $out/bin/stone-kingdoms \
      --add-flags $out/share/games/lovegames/stone-kingdoms.love
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "A real-time strategy game made with LÖVE based on the original Stronghold by Firefly studios";
      desktopName = "Stone Kingdoms";
      exec = "stone-kingdoms";
      genericName = "stone-kingdoms";
      icon = "stone-kingdoms";
      name = "stone-kingdoms";
    })
  ];

  meta = {
    description = "Real-time strategy game made with LÖVE based on the original Stronghold by Firefly studios";
    homepage = "https://gitlab.com/stone-kingdoms/stone-kingdoms";

    license = with lib.licenses; [
      asl20 # engine
      unfree # game assets
    ];

    maintainers = with lib.maintainers; [ hulr ];
    platforms = love.meta.platforms;
  };
}
