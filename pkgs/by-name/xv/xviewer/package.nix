{
  lib,
  stdenv,
  fetchFromGitHub,
  cinnamon-desktop,
  docbook_xsl,
  exempi,
  fetchpatch,
  gdk-pixbuf,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  gtk3,
  itstool,
  lcms2,
  libavif,
  libexif,
  libheif,
  libjpeg,
  libjxl,
  libpeas,
  librsvg,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  webp-pixbuf-loader,
  wrapGAppsHook3,
  xapp,
  xapp-symbolic-icons,
  yelp-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xviewer";
  version = "3.4.16";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "xviewer";
    rev = finalAttrs.version;
    hash = "sha256-ayd91gVLuSUVlCxaPSBbx7hg4tthVTaBEnl5V9YYbQw=";
  };

  patches = [
    # build: Add support for GIRepository-2.0.
    (fetchpatch {
      hash = "sha256-lL4MTvC2RvdVZ4O5RaYyK+1sHnLGPYzGNbZ99aN22U8=";
      url = "https://github.com/linuxmint/xviewer/commit/74d7d4ba2584c658ae6fb87208543671664943cc.patch";
    })
  ];

  nativeBuildInputs = [
    docbook_xsl
    gobject-introspection
    gtk-doc
    itstool
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook3
    yelp-tools
  ];

  buildInputs = [
    cinnamon-desktop
    exempi
    gdk-pixbuf
    glib
    gtk3
    lcms2
    libexif
    libjpeg
    libpeas
    librsvg
    libxml2
    xapp
  ];

  postInstall = ''
    # In postInstall to run before gappsWrapperArgsHook.
    export GDK_PIXBUF_MODULE_FILE="${
      gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
        extraLoaders = [
          libavif
          libheif.lib
          libjxl
          librsvg
          webp-pixbuf-loader
        ];
      }
    }"
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${lib.makeSearchPath "share" [ xapp-symbolic-icons ]}"
    )
  '';

  meta = {
    description = "Generic image viewer from Linux Mint";
    homepage = "https://github.com/linuxmint/xviewer";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ tu-maurice ];
    platforms = lib.platforms.linux;
    mainProgram = "xviewer";
    teams = [ lib.teams.cinnamon ];
  };
})
