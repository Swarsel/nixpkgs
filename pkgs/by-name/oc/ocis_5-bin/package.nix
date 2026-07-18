{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  arch =
    {
      aarch64-darwin = "arm64";
      aarch64-linux = "arm64";
      armv7l-linux = "arm";
      i686-linux = "386";
      x86_64-linux = "amd64";
    }
    ."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  os =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "darwin"
    else
      throw "Unsupported OS";

  hash =
    {
      hash_386-linux = "sha256-2RtkxtVk7YN7CfsIBpMP85g84MNTzrnEgk10eFdfyyw=";
      hash_amd64-darwin = "sha256-LZ6n/f2MdbFaPnBCoJqZZ7HQiLG3Z6ZoatgFsxaFvMc=";
      hash_amd64-linux = "sha256-tmUfDKLO35qCs1hauJQKhJhcnMhqOpcqDFtAggMFhLE=";
      hash_arm-linux = "sha256-uMLRow1NeHufSI5B4k5qSIfH3lTxg+WxzLxgdedAz40=";
      hash_arm64-darwin = "sha256-k5X2ZInFS/HlToOZPX23TRJqlx/XM1ZG++Xr4BHn8SY=";
      hash_arm64-linux = "sha256-ggRDW1cnTHMQKvOvCDH3eptH3O3PgYaondlzOGHTjio=";
    }
    ."hash_${arch}-${os}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ocis_5-bin";
  version = "5.0.9";

  src = fetchurl {
    inherit hash;
    url = "https://github.com/owncloud/ocis/releases/download/v${finalAttrs.version}/ocis-${finalAttrs.version}-${os}-${arch}";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -D $src $out/bin/ocis
    runHook postInstall
  '';

  dontUnpack = true;
  passthru.updateScript = ./update.py;

  meta = {
    description = "ownCloud Infinite Scale Stack";
    homepage = "https://owncloud.dev/ocis/";
    changelog = "https://github.com/owncloud/ocis/releases/tag/v${finalAttrs.version}";
    # oCIS is licensed under non-free EULA which can be found here :
    # https://github.com/owncloud/ocis/releases/download/v5.0.1/End-User-License-Agreement-for-ownCloud-Infinite-Scale.pdf
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    maintainers = with lib.maintainers; [
      ramblurr
      bhankas
      ramblurr
    ];

    platforms =
      (lib.intersectLists lib.platforms.linux (
        lib.platforms.arm ++ lib.platforms.aarch64 ++ lib.platforms.x86
      ))
      ++ (lib.intersectLists lib.platforms.darwin (lib.platforms.aarch64 ++ lib.platforms.x86_64));

    mainProgram = "ocis";
  };
})
