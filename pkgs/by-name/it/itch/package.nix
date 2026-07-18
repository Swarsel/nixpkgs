{
  lib,
  fetchFromGitHub,
  butler,
  copyDesktopItems,
  electron,
  fetchzip,
  makeDesktopItem,
  makeWrapper,
  stdenvNoCC,
  steam-run,
}:

let
  version = "26.13.0";

  itch-setup = fetchzip {
    hash = "sha256-T4xvso3jJ9XsiG7QTpYdcvcClg2ejbGS4R/+goaHl18=";
    stripRoot = false;
    url = "https://broth.itch.zone/itch-setup/linux-amd64/1.29.0/archive.zip";
  };

  sparseCheckout = "/release/images/itch-icons";
  icons =
    fetchFromGitHub {
      hash = "sha256-v/2y9F+uigGaVsEy4gaa7WGTByW1wqYosti6AEOsaQQ=";
      owner = "itchio";
      repo = "itch";
      rev = "v${version}";
      sparseCheckout = [ sparseCheckout ];
    }
    + sparseCheckout;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit version;
  pname = "itch";

  src = fetchzip {
    url = "https://github.com/itchio/itch/releases/download/v${finalAttrs.version}/itch-v${finalAttrs.version}-linux-amd64.tar.gz";
    hash = "sha256-//QA4aW9uwZ/yhKf1xJRthj36YqfXuu/6yU1yGXQeFo=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  # As taken from https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=itch-bin
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/itch/resources/app
    cp -r resources/app "$out/share/itch/resources/"

    install -Dm644 LICENSE -t "$out/share/licenses/$pkgname/"
    install -Dm644 LICENSES.chromium.html -t "$out/share/licenses/$pkgname/"

    for icon in ${icons}/icon*.png
    do
      iconsize="''${icon#${icons}/icon}"
      iconsize="''${iconsize%.png}"
      icondir="$out/share/icons/hicolor/''${iconsize}x''${iconsize}/apps/"
      install -Dm644 "$icon" "$icondir/itch.png"
    done

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${steam-run}/bin/steam-run $out/bin/itch \
      --add-flags ${electron}/bin/electron \
      --add-flags $out/share/itch/resources/app \
      --set BROTH_USE_LOCAL butler,itch-setup \
      --prefix PATH : ${butler}/bin/:${itch-setup}
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Install and play itch.io games easily";
      desktopName = "itch";
      exec = "itch %U";
      icon = "itch";

      mimeTypes = [
        "x-scheme-handler/itchio"
        "x-scheme-handler/itch"
      ];

      name = "itch";
      tryExec = "itch";
    })
  ];

  meta = {
    description = "Best way to play itch.io games";
    homepage = "https://github.com/itchio/itch";
    changelog = "https://github.com/itchio/itch/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = with lib.maintainers; [ pasqui23 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "itch";
  };
})
