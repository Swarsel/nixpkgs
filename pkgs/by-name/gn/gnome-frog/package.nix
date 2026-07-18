{
  lib,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  gettext,
  glib,
  gobject-introspection,
  gst_all_1,
  libadwaita,
  libnotify,
  libportal,
  librsvg,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  tesseract5,
  wrapGAppsHook4,
  zbar,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gnome-frog";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "TenderOwl";
    repo = "Frog";
    tag = finalAttrs.version;
    sha256 = "sha256-p1gqom9saNEIm6FXinEuIJtMGwjGfQx9uLpR2kb46Uw=";
  };

  patches = [ ./update-compatible-with-non-flatpak-env.patch ];

  postPatch = ''
    chmod +x ./build-aux/meson/postinstall.py
    patchShebangs ./build-aux/meson/postinstall.py
    substituteInPlace ./build-aux/meson/postinstall.py \
      --replace "gtk-update-icon-cache" "gtk4-update-icon-cache"
    substituteInPlace ./frog/language_manager.py --subst-var out
  '';

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    gettext
    meson
    ninja
    pkg-config
    glib
    wrapGAppsHook4
    gobject-introspection
    blueprint-compiler
    libxml2
  ];

  buildInputs = [
    librsvg
    libnotify
    libadwaita
    libportal
    zbar
    tesseract5
    gst_all_1.gstreamer
  ];

  propagatedBuildInputs = with python3Packages; [
    loguru
    nanoid
    posthog
    pygobject3
    python-dateutil
    pillow
    pytesseract
    pyzbar
    gtts
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  # This is to prevent double-wrapping the package. We'll let
  # Python do it by adding certain arguments inside of the
  # wrapper instead.
  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Intuitive text extraction tool (OCR) for GNOME desktop";
    homepage = "https://getfrog.app/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.axodentally ];
    platforms = lib.platforms.linux;
    mainProgram = "frog";
  };
})
