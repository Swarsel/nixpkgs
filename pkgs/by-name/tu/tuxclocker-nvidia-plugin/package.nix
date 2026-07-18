{
  stdenv,
  boost,
  libx11,
  libxext,
  linuxPackages,
  openssl,
  tuxclocker-plugins,
}:

stdenv.mkDerivation {
  inherit (tuxclocker-plugins)
    src
    version
    meta
    nativeBuildInputs
    ;

  pname = "tuxclocker-nvidia-plugin";

  buildInputs = [
    boost
    libx11
    libxext
    linuxPackages.nvidia_x11
    linuxPackages.nvidia_x11.settings.libXNVCtrl
    openssl
  ];

  mesonFlags = [
    "-Ddaemon=false"
    "-Dgui=false"
    "-Drequire-nvidia=true"
    "-Dplugins-cpu=false" # provided by tuxclocker-plugins
  ];
}
