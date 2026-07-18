{
  lib,
  fetchFromGitHub,
  telegram-desktop,
  withWebkit ? true,
}:

telegram-desktop.override {
  inherit withWebkit;
  pname = "materialgram";

  unwrapped = telegram-desktop.unwrapped.overrideAttrs (
    finalAttrs: previousAttrs: {
      pname = "materialgram-unwrapped";
      version = "6.7.7.1";

      src = fetchFromGitHub {
        owner = "kukuruzka165";
        repo = "materialgram";
        tag = "v${finalAttrs.version}";
        hash = "sha256-Cy0ooQZOhfE+QBaRDblKXhmqYsKJ0TfeHsfJaVLVn8o=";
        fetchSubmodules = true;
      };

      meta = previousAttrs.meta // {
        description = "Telegram Desktop fork with material icons and some improvements";

        longDescription = ''
          Telegram Desktop fork with Material Design and other improvements,
          which is based on the Telegram API and the MTProto secure protocol.
        '';

        homepage = "https://kukuruzka165.github.io/materialgram/";
        changelog = "https://github.com/kukuruzka165/materialgram/releases/tag/v${finalAttrs.version}";

        maintainers = with lib.maintainers; [
          oluceps
          aleksana
          stellessia
        ];

        mainProgram = "materialgram";
      };
    }
  );
}
