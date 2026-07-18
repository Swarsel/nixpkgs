{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  appstream-glib,
  cairo,
  desktop-file-utils,
  girara,
  gitUpdater,
  gtk-mac-integration,
  gumbo,
  jbig2dec,
  leptonica,
  libjpeg,
  meson,
  mujs,
  mupdf,
  ninja,
  openjpeg,
  pkg-config,
  tesseract,
  zathura_core,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zathura-pdf-mupdf";
  version = "2026.05.10";

  src = fetchFromGitHub {
    owner = "pwmt";
    repo = "zathura-pdf-mupdf";
    tag = finalAttrs.version;
    hash = "sha256-aHXTxmhFZrl701PhJ+jdSrWcHHt9obO24I2AInOem2I=";
  };

  postPatch = ''
    sed -i -e '/^mupdfthird =/d' -e 's/, mupdfthird//g' meson.build
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    desktop-file-utils
    appstream
    appstream-glib
  ];

  buildInputs = [
    cairo
    girara
    gumbo
    jbig2dec
    libjpeg
    mupdf
    openjpeg
    zathura_core
    tesseract
    leptonica
    mujs
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin gtk-mac-integration;

  env.PKG_CONFIG_ZATHURA_PLUGINDIR = "lib/zathura";
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Zathura PDF plugin (mupdf)";

    longDescription = ''
      The zathura-pdf-mupdf plugin adds PDF support to zathura by
      using the mupdf rendering library.
    '';

    homepage = "https://pwmt.org/projects/zathura-pdf-mupdf/";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ mithicspirit ];
    platforms = lib.platforms.unix;
  };
})
