{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  check,
  desktop-file-utils,
  file,
  gettext,
  girara,
  gitUpdater,
  glib,
  gnome,
  gtk-mac-integration,
  gtk3,
  json-glib,
  libheif,
  libintl,
  libjxl,
  librsvg,
  libseccomp,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  sqlite,
  texlive,
  versionCheckHook,
  webp-pixbuf-loader,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zathura";
  version = "2026.05.20";

  src = fetchFromGitHub {
    owner = "pwmt";
    repo = "zathura";
    tag = finalAttrs.version;
    hash = "sha256-ChrIJKPVukkW6d/grGcMJ6sZ9sctIOmyJv6TAehh1T8=";
  };

  outputs = [
    "bin"
    "man"
    "dev"
    "out"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    desktop-file-utils
    python3.pythonOnBuildForHost.pkgs.sphinx
    gettext
    wrapGAppsHook3
    libxml2
    appstream-glib
  ];

  buildInputs = [
    gtk3
    girara
    libintl
    sqlite
    glib
    file
    librsvg
    check
    json-glib
    texlive.bin.core
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux libseccomp
  ++ lib.optional stdenv.hostPlatform.isDarwin gtk-mac-integration;

  # Flag list:
  # https://github.com/pwmt/zathura/blob/master/meson_options.txt
  mesonFlags = [
    "-Dmanpages=enabled"
    "-Dconvert-icon=enabled"
    "-Dsynctex=enabled"
    "-Dtests=disabled"
    # by default, zathura searches for zathurarc under $out/etc
    "-Dsysconfdir=/etc"
    # Make sure tests are enabled for doCheck
    # (lib.mesonEnable "tests" finalAttrs.finalPackage.doCheck)
    (lib.mesonEnable "seccomp" stdenv.hostPlatform.isLinux)
    (lib.mesonEnable "landlock" stdenv.hostPlatform.isLinux)
  ];

  # add support for more image formats
  env.GDK_PIXBUF_MODULE_FILE = gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
    extraLoaders = [
      libheif.lib
      libjxl
      librsvg
      webp-pixbuf-loader
    ];
  };

  doCheck = !stdenv.hostPlatform.isDarwin;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Core component for zathura PDF viewer";
    homepage = "https://pwmt.org/projects/zathura";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ mithicspirit ];
    platforms = lib.platforms.unix;
    mainProgram = "zathura";
  };
})
