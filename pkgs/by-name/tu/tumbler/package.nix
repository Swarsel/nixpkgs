{
  lib,
  stdenv,
  fetchFromGitLab,
  ffmpegthumbnailer,
  freetype,
  gdk-pixbuf,
  gettext,
  gitUpdater,
  glib,
  gst_all_1,
  libgepub,
  libgsf,
  libheif,
  libjxl,
  libopenraw,
  librsvg,
  libxfce4util,
  pkg-config,
  poppler,
  webp-pixbuf-loader,
  wrapGAppsNoGuiHook,
  xfce4-dev-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tumbler";
  version = "4.20.1";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "tumbler";
    tag = "tumbler-${finalAttrs.version}";
    hash = "sha256-p4lAFNvCakqrsDa2FP0xbc/khx6eYqAlHwWkk8yEB7Y=";
    domain = "gitlab.xfce.org";
  };

  nativeBuildInputs = [
    gettext
    pkg-config
    xfce4-dev-tools
    wrapGAppsNoGuiHook
  ];

  buildInputs = [
    libxfce4util
    ffmpegthumbnailer
    freetype
    gdk-pixbuf
    glib
    gst_all_1.gst-plugins-base
    libgepub # optional EPUB thumbnailer support
    libgsf
    libopenraw
    poppler # technically the glib binding
  ];

  configureFlags = [ "--enable-maintainer-mode" ];

  preFixup = ''
    gappsWrapperArgs+=(
      # Thumbnailers
      --prefix XDG_DATA_DIRS : "${
        lib.makeSearchPath "share" [
          libheif.out
          libjxl
          librsvg
          webp-pixbuf-loader
        ]
      }"
      # For heif-thumbnailer in heif.thumbnailer
      --prefix PATH : "${lib.makeBinPath [ libheif ]}"
    )
  '';

  # WrapGAppsHook won't touch this binary automatically, so we wrap manually.
  postFixup = ''
    wrapGApp $out/lib/tumbler-1/tumblerd
  '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "tumbler-";
  };

  meta = {
    description = "D-Bus thumbnailer service";
    homepage = "https://gitlab.xfce.org/xfce/tumbler";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})
