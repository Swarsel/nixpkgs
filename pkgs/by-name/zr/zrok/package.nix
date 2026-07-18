{
  lib,
  stdenv,
  common-updater-scripts,
  fetchzip,
  jq,
  nix-update,
  writeShellScript,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  plat =
    {
      aarch64-darwin = "darwin_arm64";
      aarch64-linux = "linux_arm64";
      armv7l-linux = "linux_armv7";
      x86_64-linux = "linux_amd64";
    }
    .${system} or throwSystem;

  hash =
    {
      aarch64-darwin = "sha256-c5vWvb8ZhGAnmlZB/kqErC6SEXClg6vNbJheAAmqV/E=";
      aarch64-linux = "sha256-kfmMi2HeZG81CocOEK+n+UwfKz245Ya4C6iXT2L85pI=";
      armv7l-linux = "sha256-AZDoQOJMBB1k9r07URj5g8249Od5P039nf3BadzCbPY=";
      x86_64-linux = "sha256-H/KISDC58ILi6oZlLY2HdgJR9ksEt+VeJem4VIFhqcY=";
    }
    .${system} or throwSystem;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zrok";
  version = "2.0.1";

  src = fetchzip {
    inherit hash;
    url = "https://github.com/openziti/zrok/releases/download/v${finalAttrs.version}/zrok_${finalAttrs.version}_${plat}.tar.gz";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -D --mode=0755 zrok2 $out/bin/zrok
    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf --set-interpreter "$(< "$NIX_CC/nix-support/dynamic-linker")" "$out/bin/zrok"
    ''}

    runHook postInstall
  '';

  passthru.updateScript = writeShellScript "update-script" ''
    ${lib.getExe nix-update} $UPDATE_NIX_ATTR_PATH --system x86_64-linux
    latestVersion=$(nix eval --raw --file . $UPDATE_NIX_ATTR_PATH.version)
    if [[ "$latestVersion" == "$UPDATE_NIX_OLD_VERSION" ]]; then
      exit 0
    fi
    systems=$(nix eval --json -f . $UPDATE_NIX_ATTR_PATH.meta.platforms | ${lib.getExe jq} --raw-output '.[]')
    for system in $systems; do
      hash=$(nix store prefetch-file --unpack --json $(nix eval --raw --file . $UPDATE_NIX_ATTR_PATH.src.url --system "$system") | ${lib.getExe jq} --raw-output .hash)
      ${lib.getExe' common-updater-scripts "update-source-version"} $UPDATE_NIX_ATTR_PATH $latestVersion $hash --system=$system --ignore-same-version --ignore-same-hash
    done
  '';

  meta = {
    description = "Geo-scale, next-generation sharing platform built on top of OpenZiti";
    homepage = "https://zrok.io";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ lib.maintainers.bandresen ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "armv7l-linux"
      "aarch64-darwin"
    ];

    mainProgram = "zrok";
  };
})
