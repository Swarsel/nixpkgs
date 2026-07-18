{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  glibc,
  imagemagick,
  libglvnd,
  libx11,
  libxext,
  libxinerama,
  libxrandr,
  makeDesktopItem,
  makeWrapper,
  openal,
}:
let
  version = "1.3";
in
stdenv.mkDerivation {
  inherit version;
  pname = "unigine-tropics";

  src = fetchurl {
    url = "https://assets.unigine.com/d/Unigine_Tropics-${version}.run";
    sha256 = "sha256-/eA1i42/PMcoBbUJIGS66j7QpZ13oPkOi1Y6Q27TikU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    imagemagick
    copyDesktopItems
  ];

  buildInputs = [
    stdenv.cc.cc
    libx11
    libxext
    libxrandr
    libxinerama
  ];

  installPhase = ''
    bash $src --target $name

    install -D -m 0755 $name/bin/libUnigine_x86.so $out/lib/unigine/tropics/bin/libUnigine_x86.so
    install -D -m 0755 $name/bin/Tropics $out/lib/unigine/tropics/bin/Tropics
    install -D -m 0755 $name/1024x768_windowed.sh $out/bin/Tropics

    cp -R $name/data $out/lib/unigine/tropics

    wrapProgram $out/bin/Tropics \
      --prefix LD_LIBRARY_PATH : $libPath:$out/lib/unigine/tropics/bin \
      --run "cd $out/lib/unigine/tropics"

    convert -size 256x256 xc:Transparent -fill gradient:'dodgerblue-white' -stroke Transparent -draw "roundrectangle 0,0 256,256 50,50"  $name/icon.png
    convert $name/icon.png -fill white -stroke white -draw "polygon  69.2564,84.1261 117.9,84.1261 117.9,206.56 138.1,206.56 138.1,84.1261 186.744,84.1261 186.744,65.9877 69.2564,65.9877 69.2564,84.1261" $name/icon.png

    for RES in 16 24 32 48 64 128 256
    do
        mkdir -p $out/share/icons/hicolor/"$RES"x"$RES"/apps
        convert $name/icon.png -resize "$RES"x"$RES" $out/share/icons/hicolor/"$RES"x"$RES"/apps/Tropics.png
    done
    convert $name/icon.png -resize 128x128 $out/share/icons/Tropics.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "Tropics Benchmark";
      exec = "Tropics";
      genericName = "A GPU Stress test tool from the UNIGINE";
      icon = "Tropics";
      name = "Tropics";
    })
  ];

  dontUnpack = true;

  libPath = lib.makeLibraryPath [
    libglvnd
    openal
    glibc
  ];

  meta = {
    description = "Unigine Heaven GPU benchmarking tool";
    homepage = "https://benchmark.unigine.com/tropics";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];

    mainProgram = "Tropics";
  };
}
