{
  lib,
  stdenv,
  callPackage,
  ...
}@args:
let
  pname = "lmstudio";

  version_aarch64-linux = "0.4.19-2";
  hash_aarch64-linux = "sha256-okb6RxttmvVZdlg+V1P8UwCOhHgXIl+8fCRGy/JmkB4=";
  version_aarch64-darwin = "0.4.19-2";
  hash_aarch64-darwin = "sha256-rWZpkdhEGsPYv7gFA5PVWtI+RU5d5DGiLh91O1W+vj4=";
  version_x86_64-linux = "0.4.19-2";
  hash_x86_64-linux = "sha256-kR84VRYbKOYi8Y494/KFrIwzbK6nwSiorIkaIJJDeHI=";

  meta = {
    description = "LM Studio is an easy to use desktop app for experimenting with local and open-source Large Language Models (LLMs)";
    homepage = "https://lmstudio.ai/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ crertel ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "lm-studio";
  };
in
if stdenv.hostPlatform.system == "aarch64-darwin" then
  callPackage ./darwin.nix {
    inherit pname meta;
    version = version_aarch64-darwin;
    hash = args.hash or hash_aarch64-darwin;

    url =
      args.url
        or "https://installers.lmstudio.ai/darwin/arm64/${version_aarch64-darwin}/LM-Studio-${version_aarch64-darwin}-arm64.dmg";

    passthru.updateScript = ./update.sh;
  }
else if stdenv.hostPlatform.system == "aarch64-linux" then
  callPackage ./linux.nix {
    inherit pname meta;
    version = version_aarch64-linux;
    hash = args.hash or hash_aarch64-linux;

    url =
      args.url
        or "https://installers.lmstudio.ai/linux/arm64/${version_aarch64-linux}/LM-Studio-${version_aarch64-linux}-arm64.AppImage";

    passthru.updateScript = ./update.sh;
  }
else
  callPackage ./linux.nix {
    inherit pname meta;
    version = version_x86_64-linux;
    hash = args.hash or hash_x86_64-linux;

    url =
      args.url
        or "https://installers.lmstudio.ai/linux/x64/${version_x86_64-linux}/LM-Studio-${version_x86_64-linux}-x64.AppImage";

    passthru.updateScript = ./update.sh;
  }
