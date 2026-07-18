{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  desktop-file-utils,
  glib,
  gobject-introspection,
  gtk4,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python313,
  wrapGAppsHook4,
}:

let
  pythonEnv = python313.withPackages (p: [
    p.pygobject3
  ]);
in

stdenv.mkDerivation (finalAttrs: {
  pname = "millisecond";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "gaheldev";
    repo = "Millisecond";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zoobnsBUg6Bky2Rhh7qEM+MxjpaR4eF+pEkhGMizuSM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    appstream
    desktop-file-utils
    glib
    gobject-introspection
    gtk4
    meson
    ninja
    pkg-config
    pythonEnv
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  meta = {
    description = "Optimize your Linux system for low latency audio";
    homepage = "https://github.com/gaheldev/Millisecond";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      backtail
    ];

    platforms = lib.platforms.linux;
    mainProgram = "millisecond";
  };
})
