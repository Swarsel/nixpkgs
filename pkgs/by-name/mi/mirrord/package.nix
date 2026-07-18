{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  mirrord,
  testers,
}:

let
  manifest = lib.importJSON ./manifest.json;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mirrord";
  version = manifest.version;
  src = fetchurl (manifest.assets.${stdenv.hostPlatform.system});

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isElf [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isElf [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    install -D $src $out/bin/mirrord
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  passthru = {
    tests.version = testers.testVersion {
      package = mirrord;
    };

    updateScript = ./update.py;
  };

  meta = {
    description = "Run local processes in the context of Kubernetes environment";
    homepage = "https://mirrord.dev/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ aaronjheng ];
    platforms = builtins.attrNames manifest.assets;
    mainProgram = "mirrord";
  };
})
