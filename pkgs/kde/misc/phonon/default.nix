{
  lib,
  fetchurl,
  libGL,
  libGLU,
  libpulseaudio,
  mkKdeDerivation,
  pkg-config,
  qt5compat,
  qttools,
}:
mkKdeDerivation rec {
  pname = "phonon";
  version = "4.12.0";

  src = fetchurl {
    url = "mirror://kde/stable/phonon/${version}/phonon-${version}.tar.xz";
    hash = "sha256-Mof/4PvMLUqhNj+eFXRzAtCwgAkP525fIR2AnstD85o=";
  };

  cmakeFlags = [
    "-DPHONON_BUILD_QT5=0"
    "-DPHONON_BUILD_QT6=1"
  ];

  extraBuildInputs = [
    libGLU
    libGL
    libpulseaudio
    qt5compat
  ];

  extraNativeBuildInputs = [
    pkg-config
    qttools
  ];

  meta.license = with lib.licenses; [
    lgpl21Plus
    gpl2Plus
  ];

  meta.mainProgram = "phononsettings";
}
