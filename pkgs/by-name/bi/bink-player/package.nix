{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libGL,
  libx11,
  p7zip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bink-player";
  version = "2025.05";

  src = fetchurl {
    url = "https://web.archive.org/web/20250602103030if_/https://www.radgametools.com/down/Bink/BinkLinuxPlayer.7z";
    hash = "sha256-A3IDQtdYlIcU2U8uieQI6xe1SvW4BqH+5ZwPYJxr83M=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    p7zip
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    libGL
    libx11
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 BinkPlayer64 -t $out/bin/
    install -Dm755 BinkPlayer -t $out/bin/

    runHook postInstall
  '';

  unpackPhase = ''
    runHook preUnpack

    7z x $src

    runHook postUnpack
  '';

  meta = {
    description = "Play videos in the Bink format";
    homepage = "https://www.radgametools.com/bnkmain.htm";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ nilathedragon ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "BinkPlayer64";
  };
})
