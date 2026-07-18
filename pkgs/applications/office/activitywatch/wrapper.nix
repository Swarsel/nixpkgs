{
  lib,
  aw-notify,
  aw-qt,
  aw-server-rust,
  aw-watcher-afk,
  aw-watcher-window,
  symlinkJoin,
  extraWatchers ? [ ],
}:

symlinkJoin {
  inherit (aw-server-rust) version;
  pname = "activitywatch";

  paths = [
    aw-server-rust.out
    aw-qt.out
    aw-notify.out
    aw-watcher-afk.out
    aw-watcher-window.out
  ]
  ++ (lib.forEach extraWatchers (p: p.out));

  meta = {
    description = "Best free and open-source automated time tracker";
    homepage = "https://activitywatch.net/";
    changelog = "https://github.com/ActivityWatch/activitywatch/releases/tag/v${aw-server-rust.version}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ huantian ];
    platforms = lib.platforms.linux;
    mainProgram = "aw-qt";
    downloadPage = "https://github.com/ActivityWatch/activitywatch/releases";
  };
}
