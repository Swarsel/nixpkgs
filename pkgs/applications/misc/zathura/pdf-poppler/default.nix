{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  appstream-glib,
  desktop-file-utils,
  girara,
  gitUpdater,
  meson,
  ninja,
  pkg-config,
  poppler,
  zathura_core,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zathura-pdf-poppler";
  version = "2026.05.10";

  src = fetchFromGitHub {
    owner = "pwmt";
    repo = "zathura-pdf-poppler";
    tag = finalAttrs.version;
    hash = "sha256-Iks3wv9XfdTsgI00njKPW0+yCTZ5hW9N3JAb0b0PNqE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    desktop-file-utils
    appstream
    appstream-glib
    zathura_core
  ];

  buildInputs = [
    poppler
    girara
  ];

  env.PKG_CONFIG_ZATHURA_PLUGINDIR = "lib/zathura";
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Zathura PDF plugin (poppler)";

    longDescription = ''
      The zathura-pdf-poppler plugin adds PDF support to zathura by
      using the poppler rendering library.
    '';

    homepage = "https://pwmt.org/projects/zathura-pdf-poppler/";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ mithicspirit ];
    platforms = lib.platforms.unix;
  };
})
