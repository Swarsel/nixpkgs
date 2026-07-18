{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  glib,
  gtk4,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dippi";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "cassidyjames";
    repo = "dippi";
    rev = finalAttrs.version;
    hash = "sha256-PfJp4DOM4uaDaKMYeLS70LA00mCeW/jaLmduJ1Wej4k=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    meson
    ninja
    vala
    pkg-config
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  meta = {
    description = "Calculate display info like DPI and aspect ratio";
    homepage = "https://github.com/cassidyjames/dippi";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.linux;
    mainProgram = "com.cassidyjames.dippi";
  };
})
