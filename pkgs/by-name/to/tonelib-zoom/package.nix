{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  curl,
  dpkg,
  freetype,
  libglvnd,
  libjack2,
  libxcursor,
  libxinerama,
  libxrandr,
  libxrender,
}:

stdenv.mkDerivation rec {
  pname = "tonelib-zoom";
  version = "4.3.1";

  src = fetchurl {
    url = "https://www.tonelib.net/download/0129/ToneLib-Zoom-amd64.deb";
    sha256 = "sha256-4q2vM0/q7o/FracnO2xxnr27opqfVQoN7fsqTD9Tr/c=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    alsa-lib
    freetype
    libglvnd
    # webkitgtk_4_0
  ]
  ++ runtimeDependencies;

  installPhase = ''
    mv usr $out
    substituteInPlace $out/share/applications/ToneLib-Zoom.desktop --replace /usr/ $out/
  '';

  runtimeDependencies = map lib.getLib [
    curl
    libxcursor
    libxinerama
    libxrandr
    libxrender
    libjack2
  ];

  unpackCmd = "dpkg -x $curSrc source";

  meta = {
    description = "ToneLib Zoom – change and save all the settings in your Zoom(r) guitar pedal";
    homepage = "https://tonelib.net/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ToneLib-Zoom";
    # webkitgtk_4_0 was removed
    broken = true;
  };
}
