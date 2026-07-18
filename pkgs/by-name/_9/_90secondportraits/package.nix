{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  copyDesktopItems,
  fetchpatch2,
  love,
  makeDesktopItem,
  makeWrapper,
  strip-nondeterminism,
  zip,
}:

let
  pname = "90secondportraits";

  icon = fetchurl {
    sha256 = "13k6cq8s7jw77j81xfa5ri41445m778q6iqbfplhwdpja03c6faw";
    url = "http://tangramgames.dk/img/thumb/90secondportraits.png";
  };

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "A silly speed painting game";
      desktopName = "90 Second Portraits";
      exec = pname;
      genericName = "90secondportraits";
      icon = icon;
      name = "90secondportraits";
    })
  ];

in
stdenv.mkDerivation rec {
  inherit pname desktopItems;
  version = "1.01b";

  src = fetchFromGitHub {
    owner = "SimonLarsen";
    repo = "90-Second-Portraits";
    tag = version;
    hash = "sha256-xxgB8Aw7QTK9lPus7Q4E7iP2/rRfCwwiYbk5NqzujHI=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-/C4gqzwHQqZCuTA/m6WX8mvTxmLxOcHRItVLA3bty3Y=";
      # Love 11 support
      url = "https://github.com/SimonLarsen/90-Second-Portraits/commit/0ae7ba046f14cef9857fd6c05d9072455097441f.patch?full_index=true";
    })
  ];

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    strip-nondeterminism
    zip
  ];

  buildPhase = ''
    runHook preBuild
    zip -9 -r 90secondportraits.love ./*
    strip-nondeterminism --type zip 90secondportraits.love
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm444 90secondportraits.love $out/share/games/lovegames/90secondportraits.love
    makeWrapper ${lib.getExe love} $out/bin/90secondportraits \
      --add-flags $out/share/games/lovegames/90secondportraits.love
    runHook postInstall
  '';

  meta = {
    description = "Silly speed painting game";
    homepage = "https://github.com/SimonLarsen/90-Second-Portraits";

    license = with lib.licenses; [
      zlib
      cc-by-sa-40
      cc-by-sa-30 # vendored
      x11
      mit
    ];

    platforms = love.meta.platforms;
    mainProgram = "90secondportraits";
    downloadPage = "http://tangramgames.dk/games/90secondportraits";
  };

}
