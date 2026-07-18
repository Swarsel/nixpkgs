{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  appstream-glib,
  desktop-file-utils,
  djvulibre,
  gettext,
  girara,
  gitUpdater,
  gtk3,
  meson,
  ninja,
  pkg-config,
  zathura_core,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zathura-djvu";
  version = "2026.05.10";

  src = fetchFromGitHub {
    owner = "pwmt";
    repo = "zathura-djvu";
    tag = finalAttrs.version;
    hash = "sha256-LW5gQhqV4vwXj1BRlNK1ZfTdQcqt4rJtHckFLvUvPI8=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    desktop-file-utils
    appstream
    appstream-glib
  ];

  buildInputs = [
    djvulibre
    gettext
    zathura_core
    gtk3
    girara
  ];

  env.PKG_CONFIG_ZATHURA_PLUGINDIR = "lib/zathura";
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Zathura DJVU plugin";

    longDescription = ''
      The zathura-djvu plugin adds DjVu support to zathura by using the
      djvulibre library.
    '';

    homepage = "https://pwmt.org/projects/zathura-djvu/";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ mithicspirit ];
    platforms = lib.platforms.unix;
  };
})
