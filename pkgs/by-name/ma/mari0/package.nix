{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  love,
  makeDesktopItem,
  makeWrapper,
  strip-nondeterminism,
  zip,
}:

stdenv.mkDerivation {
  pname = "mari0";
  version = "1.6.2-unstable-2023-08-08";

  src = fetchFromGitHub {
    owner = "Stabyourself";
    repo = "mari0";
    rev = "57829fd23e783d1a2993b9d64a7f7e6b131e572f";
    sha256 = "sha256-rmsj6gMTleeWx911j5/sfpfQG54HDtsfsTyPDbEkLhE=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    strip-nondeterminism
    zip
  ];

  installPhase = ''
    runHook preInstall
    zip -9 -r mari0.love ./*
    strip-nondeterminism --type zip mari0.love
    install -Dm444 -t $out/share/games/lovegames/ mari0.love
    makeWrapper ${lib.getExe love} $out/bin/mari0 \
      --add-flags $out/share/games/lovegames/mari0.love
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Crossover between Super Mario Bros. and Portal";
      desktopName = "mari0";
      exec = "mari0";
      genericName = "mari0";
      name = "mari0";
    })
  ];

  meta = {
    description = "Crossover between Super Mario Bros. and Portal";
    homepage = "https://github.com/Stabyourself/mari0";
    license = lib.licenses.mit;
    platforms = love.meta.platforms;
    mainProgram = "mari0";
    downloadPage = "https://stabyourself.net/mari0/";
  };

}
