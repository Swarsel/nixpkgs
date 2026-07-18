{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  makeDesktopItem,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "google-chat-linux";
  version = "5.39.24-1";

  src = fetchFromGitHub {
    owner = "squalou";
    repo = "google-chat-linux";
    tag = version;
    hash = "sha256-yQBnqGyTCUr/t+PCCSTsUhKvlT5wV/F/OvCXrgeiceA=";
  };

  postPatch = ''
    # https://github.com/electron/electron/issues/31121
    substituteInPlace src/paths.js \
      --replace-fail "process.resourcesPath" "'$out/lib/node_modules/${pname}/assets'"
  '';

  nativeBuildInputs = [
    copyDesktopItems
  ];

  npmDepsHash = "sha256-8eZAn8zIDcMDKi30AiG1di4T/3xVoCewJ/e4qf7n9nY=";
  # npm install will error when electron tries to download its binary
  # we don't need it anyways since we wrap the program with our nixpkgs electron
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postInstall = ''
    mkdir -p $out/share/icons
    ln -s $out/lib/node_modules/${pname}/build/icons/icon.png $out/share/icons/${pname}.png
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/lib/node_modules/${pname}/
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "InstantMessaging"
      ];

      comment = meta.description;
      desktopName = "Google Chat";
      exec = "google-chat-linux";
      icon = "google-chat-linux";
      name = "google-chat-linux";
    })
  ];

  dontNpmBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Electron-base client for Google Hangouts Chat";
    homepage = "https://github.com/squalou/google-chat-linux";
    changelog = "https://github.com/squalou/google-chat-linux/releases/tag/${version}";
    license = lib.licenses.wtfpl;

    maintainers = with lib.maintainers; [
      cterence
    ];

    platforms = lib.platforms.linux;
    mainProgram = "google-chat-linux";
    downloadPage = "https://github.com/squalou/google-chat-linux/releases";
  };
}
