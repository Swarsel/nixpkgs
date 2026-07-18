{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cmake,
  expat,
  fftwSinglePrec,
  fluidsynth,
  glib,
  gnome2,
  gtk2,
  ladspa-header,
  libjack2,
  lv2,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "calf";
  version = "0.90.6";

  src = fetchFromGitHub {
    owner = "calf-studio-gear";
    repo = "calf";
    tag = finalAttrs.version;
    hash = "sha256-rcMuQFig6BrnyGFyvYaAHmOvabEHGl+1lMNfffLHn1w=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cairo
    expat
    fftwSinglePrec
    fluidsynth
    glib
    gtk2
    libjack2
    ladspa-header
    gnome2.libglade
    lv2
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Set of high quality open source audio plugins for musicians";
    homepage = "https://calf-studio-gear.org";
    license = lib.licenses.lgpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "calfjackhost";
  };
})
