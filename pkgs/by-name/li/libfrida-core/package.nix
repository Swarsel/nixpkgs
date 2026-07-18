{
  lib,
  fetchurl,
  common-updater-scripts,
  curl,
  jq,
  stdenvNoCC,
  writeShellScript,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "libfrida-core";
  version = "17.15.4";

  src =
    finalAttrs.passthru.sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include $out/lib
    tar -xf $src -C .
    install -Dm755 libfrida-core.a -t $out/lib
    install -Dm644 frida-core.h -t $out/include
    runHook postInstall
  '';

  dontUnpack = true;

  passthru = {
    sources = {
      aarch64-darwin = fetchurl {
        hash = "sha256-CmOkZ+/w/Vh6V5lJ8jzXU5ZLi0FWXXXIFgPLdb+nu88=";
        url = "https://github.com/frida/frida/releases/download/${finalAttrs.version}/frida-core-devkit-${finalAttrs.version}-macos-arm64.tar.xz";
      };

      aarch64-linux = fetchurl {
        hash = "sha256-ryGe+T9GP3CitQMZHwco0d5tNoyXQ9TUwRG2D5E+Hp0=";
        url = "https://github.com/frida/frida/releases/download/${finalAttrs.version}/frida-core-devkit-${finalAttrs.version}-linux-arm64.tar.xz";
      };

      x86_64-linux = fetchurl {
        hash = "sha256-VzPu6AYN8LVQULJBb4Ug7GrenyklksORpcZoj9Sg354=";
        url = "https://github.com/frida/frida/releases/download/${finalAttrs.version}/frida-core-devkit-${finalAttrs.version}-linux-x86_64.tar.xz";
      };
    };

    updateScript = writeShellScript "update-libfrida-core" ''
      set -o errexit
      export PATH="${
        lib.makeBinPath [
          curl
          jq
          common-updater-scripts
        ]
      }"
      NEW_VERSION=$(curl --silent ''${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} https://api.github.com/repos/frida/frida/releases/latest | jq '.tag_name' --raw-output)
      if [[ "${finalAttrs.version}" = "$NEW_VERSION" ]]; then
        echo "The new version is the same as the old version."
        exit 0
      fi
      for platform in ${lib.escapeShellArgs finalAttrs.meta.platforms}; do
        update-source-version "libfrida-core" "$NEW_VERSION" --ignore-same-version --source-key="sources.$platform"
      done
    '';
  };

  meta = {
    description = "Frida core library intended for static linking into bindings";
    homepage = "https://frida.re/";
    changelog = "https://frida.re/news/";
    license = lib.licenses.wxWindowsException31;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ nilathedragon ];
    platforms = builtins.attrNames finalAttrs.passthru.sources;
  };
})
