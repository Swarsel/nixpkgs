{
  lib,
  stdenv,
  fetchurl,
  gobject-introspection,
  goocanvas_2,
  gtk3,
  gtkspell3,
  intltool,
  isocodes,
  itstool,
  libxml2,
  pkg-config,
  python3,
  tesseract4,
  wrapGAppsHook3,
  extraOcrEngines ? [ ], # other supported engines are: ocrad gocr cuneiform
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ocrfeeder";
  version = "0.8.5";

  src = fetchurl {
    url = "mirror://gnome/sources/ocrfeeder/${lib.versions.majorMinor finalAttrs.version}/ocrfeeder-${finalAttrs.version}.tar.xz";
    hash = "sha256-sD0qWUndguJzTw0uy0FIqupFf4OX6dTFvcd+Mz+8Su0=";
  };

  patches = [
    # Compiles, but doesn't launch without this, see:
    # https://gitlab.gnome.org/GNOME/ocrfeeder/-/issues/83
    ./fix-launch.diff
  ];

  postPatch = ''
    substituteInPlace configure \
      --replace-fail "import imp" "import importlib.util" \
      --replace-fail "imp.find_module" "importlib.util.find_spec" \
      --replace-fail "distutils" "setuptools._distutils"
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    intltool
    itstool
    libxml2
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    goocanvas_2
    gtkspell3
    isocodes
    (python3.withPackages (
      ps: with ps; [
        pyenchant
        sane
        pillow
        reportlab
        odfpy
        pygobject3
        standard-imghdr
      ]
    ))
  ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : "${finalAttrs.enginesPath}")
    gappsWrapperArgs+=(--set ISO_CODES_DIR "${isocodes}/share/xml/iso-codes")
  '';

  enginesPath = lib.makeBinPath (
    [
      tesseract4
    ]
    ++ extraOcrEngines
  );

  meta = {
    description = "Complete Optical Character Recognition and Document Analysis and Recognition program";
    homepage = "https://gitlab.gnome.org/GNOME/ocrfeeder";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.linux;
  };
})
