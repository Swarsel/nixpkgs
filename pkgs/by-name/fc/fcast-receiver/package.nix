{
  lib,
  fetchFromGitLab,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  makeDesktopItem,
  makeWrapper,
  rsync,
}:

buildNpmPackage rec {
  pname = "fcast-receiver";
  version = "2.2.1";

  src = fetchFromGitLab {
    owner = "videostreaming";
    repo = "fcast";
    rev = "520907fbb8e3103d7eab9d925e572a966f4e74f3";
    hash = "sha256-5ERnlX4Jw6kv0BSNNA2mnJCYoIQJDuUrZVoKIYuWBYA=";
    domain = "gitlab.futo.org";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    rsync
  ];

  npmDepsHash = "sha256-EgNpKOjpv7QMsmcVGEpU81UIi/z4vA1S8xXmespx6Ew=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postInstall = ''
    install -Dm644 assets/icons/app/icon.png $out/share/icons/hicolor/512x512/apps/fcast-receiver.png
    ln -s $out/lib/node_modules/fcast-receiver/package.json $out/lib/node_modules/fcast-receiver/dist/package.json

    makeWrapper ${electron}/bin/electron $out/bin/fcast-receiver \
      --add-flags $out/lib/node_modules/fcast-receiver/dist/bundle.js
  '';

  desktopItems = [
    (makeDesktopItem {
      comment = "FCast Receiver, an open-source media streaming receiver";
      desktopName = "FCast Receiver";
      exec = "fcast-receiver";
      genericName = "Media Streaming Receiver";
      icon = "fcast-receiver";
      name = "fcast-receiver";
    })
  ];

  makeCacheWritable = true;
  sourceRoot = "${src.name}/receivers/electron";

  meta = {
    description = "FCast Receiver, an open-source media streaming receiver";

    longDescription = ''
      FCast Receiver is a receiver for an open-source media streaming protocol, FCast, an alternative to Chromecast and AirPlay.
    '';

    homepage = "https://fcast.org/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ymstnt ];
    platforms = lib.platforms.linux;
    mainProgram = "fcast-receiver";
  };
}
