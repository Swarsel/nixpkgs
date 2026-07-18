{
  lib,
  fetchFromGitHub,
  telegram-desktop,
  withWebkit ? true,
}:

telegram-desktop.override {
  inherit withWebkit;
  pname = "64gram";

  unwrapped = telegram-desktop.unwrapped.overrideAttrs (old: rec {
    pname = "64gram-unwrapped";
    version = "1.2.5";

    src = fetchFromGitHub {
      owner = "TDesktop-x64";
      repo = "tdesktop";
      tag = "v${version}";
      hash = "sha256-CcYcdSgeVEbGKOzim+Q/gIxMIfDGaSStF4cLLttA+SM=";
      fetchSubmodules = true;
    };

    meta = {
      description = "Unofficial Telegram Desktop providing Windows 64bit build and extra features";
      homepage = "https://github.com/TDesktop-x64/tdesktop";
      changelog = "https://github.com/TDesktop-x64/tdesktop/releases/tag/v${version}";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ clot27 ];
      platforms = lib.platforms.all;
      mainProgram = "Telegram";
    };
  });
}
