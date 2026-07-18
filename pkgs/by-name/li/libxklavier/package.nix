{
  lib,
  stdenv,
  autoreconfHook,
  docbook_xsl,
  fetchgit,
  fetchpatch,
  glib,
  gobject-introspection,
  gtk-doc,
  isocodes,
  libice,
  libx11,
  libxi,
  libxkbfile,
  libxml2,
  pkg-config,
  xkbcomp,
  xkeyboard_config,
  withDoc ? (stdenv.buildPlatform == stdenv.hostPlatform),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libxklavier";
  version = "5.4";

  src = fetchgit {
    url = "https://gitlab.freedesktop.org/archived-projects/libxklavier.git";
    tag = "libxklavier-${finalAttrs.version}";
    hash = "sha256-6uzfuVaQlnMMURIke+ZLqL0PhPEmCzx4bFR4+nItPfA=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optionals withDoc [ "devdoc" ];

  patches = [
    ./honor-XKB_CONFIG_ROOT.patch
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    (fetchpatch {
      sha256 = "sha256-fyWu7sVfDv/ozjhLSLCVsv+iNFawWgJqHUsQHHSkQn4=";
      url = "https://gitlab.freedesktop.org/archived-projects/libxklavier/-/commit/1387c21a788ec1ea203c8392ea1460fc29d83f70.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    gtk-doc
    docbook_xsl
    gobject-introspection
  ];

  # TODO: enable xmodmap support, needs xmodmap DB
  propagatedBuildInputs = [
    libx11
    libxi
    xkeyboard_config
    libxml2
    libice
    glib
    libxkbfile
    isocodes
  ];

  configureFlags = [
    "--with-xkb-base=${xkeyboard_config}/etc/X11/xkb"
    "--with-xkb-bin-base=${xkbcomp}/bin"
    "--disable-xmodmap-support"
    "${if withDoc then "--enable-gtk-doc" else "--disable-gtk-doc"}"
  ];

  depsBuildBuild = [
    pkg-config
  ];

  preAutoreconf = ''
    export NOCONFIGURE=1
    gtkdocize
  '';

  meta = {
    description = "Library providing high-level API for X Keyboard Extension known as XKB";
    homepage = "http://freedesktop.org/wiki/Software/LibXklavier";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
  };
})
