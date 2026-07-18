{
  lib,
  fetchFromGitHub,
  cabextract,
  copyDesktopItems,
  coreutils,
  findutils,
  libnotify,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  stdenvNoCC,
  unzip,
  winetricks,
  zenity,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lug-helper";
  version = "4.13";

  src = fetchFromGitHub {
    owner = "starcitizen-lug";
    repo = "lug-helper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+hhipbw6tZmjpX+eUFQqRl4WXV4t56yJDrx4HtJ8AXc=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    coreutils
    findutils
    zenity
  ];

  postInstall = ''
    install -Dm755 lug-helper.sh $out/bin/lug-helper
    install -Dm644 lug-logo.png $out/share/icons/hicolor/256x256/apps/lug-logo.png
    install -Dm644 rsi-launcher.png $out/share/icons/hicolor/256x256/apps/rsi-launcher.png
    install -Dm644 lib/* -t $out/share/lug-helper

    wrapProgram $out/bin/lug-helper \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          findutils
          zenity
          cabextract
          unzip
          libnotify
          winetricks
        ]
      } \
      --prefix XDG_DATA_DIRS : "$out"

  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "Star Citizen LUG Helper";
      desktopName = "LUG Helper";
      exec = "lug-helper";
      icon = "lug-logo";
      mimeTypes = [ "application/x-lug-helper" ];
      name = "lug-helper";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Script to manage and optimize Star Citizen on Linux";
    homepage = "https://github.com/starcitizen-lug/lug-helper";
    changelog = "https://github.com/starcitizen-lug/lug-helper/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fuzen ];
    platforms = lib.platforms.linux;
    mainProgram = "lug-helper";
  };
})
