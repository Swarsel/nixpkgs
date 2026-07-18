{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  autoPatchelfHook,
  cairo,
  copyDesktopItems,
  curl,
  genericUpdater,
  gnugrep,
  gnused,
  libgcc,
  libvorbis,
  makeBinaryWrapper,
  makeDesktopItem,
  openal,
  pango,
  python313,
  writeShellApplication,
  commandLineArgs ? "",
}:
let
  archive =
    {
      aarch64-linux = {
        hash = "sha256-Q87KbQqwEOaMiJ4uSgZ3eD8AYKQCoJWPzq7rt9Nu9Co=";
        name = "BombSquad_Linux_Arm64";
      };

      x86_64-linux = {
        hash = "sha256-zKZpRsyBCTYDJbTwjaP/HFXfYvD9zBhetUGzriB9754=";
        name = "BombSquad_Linux_x86_64";
      };
    }
    .${stdenv.targetPlatform.system} or (throw "${stdenv.targetPlatform.system} is unsupported.");

  bombsquadIcon = fetchurl {
    hash = "sha256-MfOvjVmjhLejrJmdLo/goAM9DTGubnYGhlN6uF2GugA=";
    url = "https://files.ballistica.net/bombsquad/promo/BombSquadIcon.png";
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "bombsquad";
  # Note: This version trails behind the latest version by one since the latest
  # version sometimes gets replaced for minor updates. The builds in /old/ are
  # stable.
  version = "1.7.63";

  src = fetchurl {
    inherit (archive) hash;
    url = "https://files.ballistica.net/bombsquad/builds/old/${archive.name}_${finalAttrs.version}.tar.gz";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeBinaryWrapper
  ];

  buildInputs = [
    SDL2
    cairo
    libgcc
    libvorbis
    openal
    pango
    python313
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec $out/share/bombsquad/ba_data

    install -Dm555 -t $out/libexec ${finalAttrs.meta.mainProgram}
    # x86_64 bundles Discord partner SDK; aarch64 currently does not.
    if [ -e libdiscord_partner_sdk.so ]; then
      install -Dm555 -t $out/libexec libdiscord_partner_sdk.so
    fi
    cp -r ba_data $out/share/bombsquad

    makeWrapper "$out/libexec/${finalAttrs.meta.mainProgram}" "$out/bin/${finalAttrs.meta.mainProgram}" \
      --add-flags ${lib.escapeShellArg commandLineArgs} \
      --add-flags "-d $out/share/bombsquad"

    install -Dm444 ${bombsquadIcon} $out/share/icons/bombsquad.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "An explosive arcade-style party game.";
      desktopName = "BombSquad";
      exec = "bombsquad";
      genericName = "bombsquad";
      icon = "bombsquad";
      name = "bombsquad";
    })
  ];

  sourceRoot = "${archive.name}_${finalAttrs.version}";

  passthru.updateScript = genericUpdater {
    versionLister = lib.getExe (writeShellApplication {
      name = "bombsquad-versionLister";

      runtimeInputs = [
        curl
        gnugrep
        gnused
      ];

      text = ''
        curl -sL "https://files.ballistica.net/bombsquad/builds/CHANGELOG.md" \
            | grep -oP '^### \K\d+\.\d+\.\d+' \
            | sed -n 2p
      '';
    });
  };

  meta = {
    description = "Free, multiplayer, arcade-style game for up to eight players that combines elements of fighting games and first-person shooters (FPS)";
    homepage = "https://ballistica.net";
    changelog = "https://ballistica.net/downloads?display=changelog";

    license = with lib.licenses; [
      mit
      unfree
    ];

    maintainers = with lib.maintainers; [
      syedahkam
      mrmaxmeier
    ];

    platforms = lib.platforms.linux;
    mainProgram = "bombsquad";
  };
})
