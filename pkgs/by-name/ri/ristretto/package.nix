{
  lib,
  stdenv,
  fetchFromGitLab,
  cairo,
  gitUpdater,
  glib,
  gnome,
  gtk3,
  libexif,
  libheif,
  libjxl,
  librsvg,
  libxfce4ui,
  libxfce4util,
  meson,
  ninja,
  pkg-config,
  webp-pixbuf-loader,
  wrapGAppsHook3,
  xfce4-exo,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ristretto";
  version = "0.14.0";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "ristretto";
    tag = "ristretto-${finalAttrs.version}";
    hash = "sha256-3Jlm0fqFKOQF9DG1hqc7P2MrILDe/gKkxkT9WPRflBo=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    glib # glib-compile-schemas
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    xfce4-exo
    glib
    gtk3
    libexif
    libxfce4ui
    libxfce4util
    xfconf
  ];

  postInstall = ''
    # Pull in HEIF, JXL and WebP support for ristretto.
    # In postInstall to run before gappsWrapperArgsHook.
    export GDK_PIXBUF_MODULE_FILE="${
      gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
        extraLoaders = [
          libheif.lib
          libjxl
          librsvg
          webp-pixbuf-loader
        ];
      }
    }"
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "ristretto-"; };

  meta = {
    description = "Fast and lightweight picture-viewer for the Xfce desktop environment";
    homepage = "https://gitlab.xfce.org/apps/ristretto";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "ristretto";
    teams = [ lib.teams.xfce ];
  };
})
