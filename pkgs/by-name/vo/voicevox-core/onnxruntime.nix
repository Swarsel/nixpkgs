{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "voicevox-onnxruntime";
  version = "1.17.3";
  src = finalAttrs.passthru.sources.${stdenv.hostPlatform.system};
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r ./lib "$out/lib"

    runHook postInstall
  '';

  passthru.sources =
    let
      # Note: Only the prebuilt binaries are able to decrypt the encrypted voice models
      fetchArtifact =
        { hash, id }:
        fetchurl {
          inherit hash;
          url = "https://github.com/VOICEVOX/onnxruntime-builder/releases/download/voicevox_onnxruntime-${finalAttrs.version}/voicevox_onnxruntime-${id}-${finalAttrs.version}.tgz";
        };
    in
    {
      "aarch64-darwin" = fetchArtifact {
        hash = "sha256-ltfqGSigoVSFSS03YhOH31D0CnkuKmgX1N9z7NGFcfI=";
        id = "osx-arm64";
      };

      "aarch64-linux" = fetchArtifact {
        hash = "sha256-J27twAe2lDJPWbw1ws+QQXJOt4ZghDemSfCW7eo5Q6k=";
        id = "linux-arm64";
      };

      "x86_64-linux" = fetchArtifact {
        hash = "sha256-crUof91I3IM6mSn26eOCbnk7VM4SAhgb6T9jgjoiL1g=";
        id = "linux-x64";
      };
    };

  meta = {
    license = with lib.licenses; [
      mit
      {
        free = false;
        name = "VOICEVOX ONNX Runtime Terms of Use";
        redistributable = true;
        url = "https://github.com/VOICEVOX/voicevox_resource/blob/main/onnxruntime/README.md";
      }
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      tomasajt
      eljamm
    ];

    platforms = lib.attrNames finalAttrs.passthru.sources;
  };
})
