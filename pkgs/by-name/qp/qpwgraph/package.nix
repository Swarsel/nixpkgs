{
  lib,
  stdenv,
  fetchFromGitLab,
  alsa-lib,
  cmake,
  kdePackages,
  pipewire,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qpwgraph";
  version = "1.0.2";

  src = fetchFromGitLab {
    owner = "rncbc";
    repo = "qpwgraph";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-mCsjNkQw4yalwZvkMzEmK/NVviVZCLxkROtaNrgEAUo=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtsvg
    kdePackages.qtwayland
    alsa-lib
    pipewire
  ];

  cmakeFlags = [ "-DCONFIG_WAYLAND=ON" ];

  meta = {
    description = "Qt graph manager for PipeWire, similar to QjackCtl";

    longDescription = ''
      qpwgraph is a graph manager dedicated for PipeWire,
      using the Qt C++ framework, based and pretty much like
      the same of QjackCtl.
    '';

    homepage = "https://gitlab.freedesktop.org/rncbc/qpwgraph";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      kanashimia
      exi
      Scrumplex
      matthiasbeyer
    ];

    platforms = lib.platforms.linux;
    mainProgram = "qpwgraph";
  };
})
