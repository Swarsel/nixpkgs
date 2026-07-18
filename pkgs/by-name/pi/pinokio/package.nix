{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  pkgs,
}:
let
  pname = "pinokio";
  version = "1.3.4";
  src =
    fetchurl
      {
        x86_64-linux = {
          hash = "sha256-/E/IAOUgxH9RWpE2/vLlQy92LOgwpHF79K/1XEtSpXI=";
          url = "https://github.com/pinokiocomputer/pinokio/releases/download/${version}/Pinokio-${version}.AppImage";
        };
      }
      .${stdenv.system} or (throw "Unsupported system: ${stdenv.system}");

  appimageContents = appimageTools.extractType2 { inherit pname version src; };

  meta = {
    description = "Browser to install, run, and programmatically control ANY application automatically";
    homepage = "https://pinokio.computer";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ByteSudoer ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "pinokio";
  };
in

if stdenv.hostPlatform.isDarwin then
  stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = with pkgs; [ undmg ];

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      mv Pinokio.app $out/Applications/
      runHook postInstall
    '';

    sourceRoot = ".";
  }
else
  appimageTools.wrapType2 {
    inherit
      pname
      version
      src
      meta
      ;

    extraInstallCommands = ''
      mkdir -p $out/share/pinokio
      cp -a ${appimageContents}/{locales,resources} $out/share/pinokio
      cp -a ${appimageContents}/usr/share/icons $out/share/
      install -Dm 444 ${appimageContents}/pinokio.desktop -t $out/share/applications
    '';

  }
