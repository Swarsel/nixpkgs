{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  gst_all_1,
  gtk3,
  intltool,
  keybinder3,
  libappindicator-gtk3,
  libcanberra-gtk3,
  libgudev,
  libpulseaudio,
  libwnck,
  python3Packages,
  replaceVars,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "kazam";
  version = "1.5.5-unstable-2025-01-02";

  src = fetchFromGitHub {
    owner = "niknah";
    repo = "kazam";
    rev = "b6c1bddc9ac93aad50476f2c87fec9f0cf204f2a";
    hash = "sha256-xllpNoKeSXVWZhzlY60ZDnWIKoAW+cd08Tb1413Ldpk=";
  };

  patches = [
    # Fix paths
    (replaceVars ./fix-paths.patch {
      inherit libpulseaudio;
      libcanberra = libcanberra-gtk3;
    })
  ];

  nativeBuildInputs = [
    gobject-introspection
    intltool
    wrapGAppsHook3
  ];

  buildInputs = [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gtk3
    libwnck
    keybinder3
    libappindicator-gtk3
    libgudev
  ];

  # no tests
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
    distutils-extra
  ];

  dependencies = with python3Packages; [
    distro
    pygobject3
    pyxdg
    pycairo
    dbus-python
    python-xlib
  ];

  pyproject = true;
  pythonImportsCheck = [ "kazam" ];

  meta = {
    description = "Screencasting program created with design in mind";
    homepage = "https://github.com/niknah/kazam";
    changelog = "https://github.com/niknah/kazam/raw/${finalAttrs.src.rev}/NEWS";
    license = lib.licenses.lgpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "kazam";
  };
})
