{
  lib,
  stdenv,
  fetchurl,
  alglib,
  autoPatchelfHook,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "rainbowcrack";
  version = "1.8";

  src = fetchurl {
    url = "http://project-rainbowcrack.com/rainbowcrack-${version}-linux64.zip";
    hash = "sha256-xMC9teHiDvBY/VHV63TsNQjdcuLqHGeXUyjHvRTO9HQ=";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
  ];

  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  installPhase = ''
    install -Dm644 $out/rainbowcrack-1.8-linux64/*.txt $out/share/rainbowcrack
    install -Dm755 $out/rainbowcrack-1.8-linux64/rt* $out/rainbowcrack-1.8-linux64/rcrack $out/bin
    chmod +x $out/bin/*
    rm -rf $out/rainbowcrack-1.8-linux64
  '';

  dontBuild = true;
  dontConfigure = true;
  runtimeDependencies = [ alglib ];

  unpackPhase = ''
    mkdir -p $out/{bin,share/rainbowcrack}
    unzip $src -d $out || true
  '';

  meta = {
    description = "Rainbow table generator used for password cracking";
    homepage = "http://project-rainbowcrack.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ tochiaha ];
    platforms = [ "x86_64-linux64" ];
    mainProgram = "rcrack";
  };
}
