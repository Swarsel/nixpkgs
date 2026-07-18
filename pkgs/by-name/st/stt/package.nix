{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  bzip2,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stt";
  version = "1.4.0";

  src = fetchurl {
    url = "https://github.com/coqui-ai/STT/releases/download/v${finalAttrs.version}/native_client.tflite.Linux.tar.xz";
    hash = "sha256-RVYc64pLYumQoVUEFZdxfUUaBMozaqgD0h/yiMaWN90=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    bzip2
    xz
    (lib.getLib stdenv.cc.cc)
  ];

  installPhase = ''
    install -D stt $out/bin/stt
    install -D coqui-stt.h $out/include/coqui-stt.h
    install -D libkenlm.so $out/lib/libkenlm.so
    install -D libsox.so.3 $out/lib/libsox.so.3
    install -D libstt.so $out/lib/libstt.so
  '';

  sourceRoot = ".";

  meta = {
    description = "Deep learning toolkit for Speech-to-Text, battle-tested in research and production";
    homepage = "https://github.com/coqui-ai/STT";
    license = lib.licenses.mpl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ rvolosatovs ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "stt";
  };
})
