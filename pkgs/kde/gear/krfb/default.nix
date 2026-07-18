{
  libvncserver,
  libxdamage,
  mkKdeDerivation,
  pipewire,
  pkg-config,
  qtbase,
}:
mkKdeDerivation {
  pname = "krfb";

  extraBuildInputs = [
    libvncserver
    pipewire
    libxdamage
  ];

  extraCmakeFlags = [
    "-DQtWaylandScanner_EXECUTABLE=${qtbase}/libexec/qtwaylandscanner"
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
