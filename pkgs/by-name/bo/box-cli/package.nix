{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
}:

let
  sources = lib.importJSON ./sources.json;
  platform =
    sources.platforms.${stdenv.hostPlatform.system}
      or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation (finalAttrs: {
  inherit (sources) version;
  pname = "box-cli";

  src = fetchurl {
    inherit (platform) hash;
    url = "https://github.com/ariana-dot-dev/agent-server/releases/download/${sources.tag}/${platform.filename}";
  };

  strictDeps = true;
  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/box

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontUnpack = true;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "CLI for Ascii Box cloud sandboxes";
    homepage = "https://ascii.dev";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ pwnwriter ];
    platforms = lib.attrNames sources.platforms;
    mainProgram = "box";
  };
})
