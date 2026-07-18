{
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
  glib,
  gobject-introspection,
  gtk3,
  itstool,
  meson,
  ninja,
  pango,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "drawing";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "maoschanz";
    repo = "drawing";
    tag = finalAttrs.version;
    hash = "sha256-kNF9db8NoHWW1A0WEFQzxHqAQ4A7kxInMRZFJOXQX/k=";
  };

  postPatch = ''
    chmod +x build-aux/meson/postinstall.py # patchShebangs requires executable file
    patchShebangs build-aux/meson/postinstall.py
  '';

  strictDeps = false;

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    glib
    gettext
    itstool
  ];

  buildInputs = [
    glib
    gtk3
    gdk-pixbuf
    pango
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pycairo
    pygobject3
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  # Prevent double wrapping because of wrapGAppsHook3
  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Free basic image editor, similar to Microsoft Paint, but aiming at the GNOME desktop";
    homepage = "https://maoschanz.github.io/drawing/";
    changelog = "https://github.com/maoschanz/drawing/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mothsart ];
    platforms = lib.platforms.linux;
    mainProgram = "drawing";
  };
})
