{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  appstream-glib,
  desktop-file-utils,
  gettext,
  girara,
  gitUpdater,
  libarchive,
  meson,
  ninja,
  pkg-config,
  zathura_core,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zathura-cb";
  version = "2026.05.10";

  src = fetchFromGitHub {
    owner = "pwmt";
    repo = "zathura-cb";
    tag = finalAttrs.version;
    hash = "sha256-rSRUNPmmAXmxarAE+y4cwfvAZ9AajeaWLWoRFo5DZ7M=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    desktop-file-utils
    appstream
    appstream-glib
  ];

  buildInputs = [
    libarchive
    zathura_core
    girara
  ];

  env.PKG_CONFIG_ZATHURA_PLUGINDIR = "lib/zathura";
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Zathura CB plugin";

    longDescription = ''
      The zathura-cb plugin adds comic book support to zathura.
    '';

    homepage = "https://pwmt.org/projects/zathura-cb/";
    license = lib.licenses.zlib;

    maintainers = with lib.maintainers; [
      jlesquembre
      mithicspirit
    ];

    platforms = lib.platforms.unix;
  };
})
