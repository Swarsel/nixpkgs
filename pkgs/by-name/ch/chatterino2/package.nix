{
  lib,
  fetchFromGitHub,
  callPackage,
  gitUpdater,
}:

(callPackage ./common.nix { }).overrideAttrs (
  finalAttrs: _: {
    pname = "chatterino2";
    version = "2.5.5";

    src = fetchFromGitHub {
      owner = "Chatterino";
      repo = "chatterino2";
      tag = "v${finalAttrs.version}";
      hash = "sha256-bTf3UECylAdb0l0+tItbhmiyNDSkxY8hgNPJHuOmwtE=";
      fetchSubmodules = true;
      leaveDotGit = true;

      postFetch = ''
        git -C $out rev-parse --short HEAD > $out/GIT_HASH
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };

    passthru = {
      buildChatterino = args: callPackage ./common.nix args;

      updateScript = gitUpdater {
        ignoredVersions = "beta";
        rev-prefix = "v";
      };
    };

    meta = {
      description = "Chat client for Twitch chat";

      longDescription = ''
        Chatterino is a chat client for Twitch chat. It aims to be an
        improved/extended version of the Twitch web chat. Chatterino 2 is
        the second installment of the Twitch chat client series
        "Chatterino".
      '';

      homepage = "https://github.com/Chatterino/chatterino2";
      changelog = "https://github.com/Chatterino/chatterino2/blob/${finalAttrs.src.rev}/CHANGELOG.md";
      license = lib.licenses.mit;

      maintainers = with lib.maintainers; [
        supa
        marie
      ];

      platforms = lib.platforms.unix;
      mainProgram = "chatterino";
    };
  }
)
