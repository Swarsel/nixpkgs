{
  lib,
  fetchurl,
  _7zz,
  stdenvNoCC,
  undmg,
}:

let
  source = import ./source.nix;
in
stdenvNoCC.mkDerivation {
  inherit (source) version;
  pname = "chatgpt";
  src = fetchurl source.src;

  nativeBuildInputs = [
    undmg
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    mkdir -p "$out/bin"
    cp -a ChatGPT.app "$out/Applications"
    ln -s "$out/Applications/ChatGPT.app/Contents/MacOS/ChatGPT" "$out/bin/ChatGPT"

    runHook postInstall
  '';

  sourceRoot = ".";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Desktop application for ChatGPT";
    homepage = "https://openai.com/chatgpt/desktop/";
    changelog = "https://help.openai.com/en/articles/9703738-macos-app-release-notes";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ wattmto ];
    platforms = lib.platforms.darwin;
    mainProgram = "ChatGPT";
  };
}
