{
  lib,
  fetchurl,
  bash,
  dbus,
  desktop-file-utils,
  gobject-introspection,
  gtk3,
  intltool,
  itstool,
  keybinder3,
  libwnck,
  python3Packages,
  shared-mime-info,
  wafHook,
  wrapGAppsHook3,
}:

with python3Packages;

buildPythonApplication (finalAttrs: {
  pname = "kupfer";
  version = "329";

  src = fetchurl {
    url = "https://github.com/kupferlauncher/kupfer/releases/download/v${finalAttrs.version}/kupfer-v${finalAttrs.version}.tar.xz";
    sha256 = "sha256-9kX30EYYkb7s/T5VfpyqZQ5F1wpvtWfTT790LZmVqq0=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    intltool
    # For setup hook
    gobject-introspection
    wafHook
    itstool # for help pages
    desktop-file-utils # for update-desktop-database
    shared-mime-info # for update-mime-info
    docutils # for rst2man
    dbus # for detection of dbus-send during build
  ];

  buildInputs = [
    libwnck
    keybinder3
    bash
  ];

  propagatedBuildInputs = [
    pygobject3
    gtk3
    pyxdg
    dbus-python
    pycairo
  ];

  doCheck = false; # no tests

  postInstall = ''
    gappsWrapperArgs+=(
      "--prefix" "PYTHONPATH" : "${makePythonPath finalAttrs.propagatedBuildInputs}"
      "--set" "PYTHONNOUSERSITE" "1"
    )
  '';

  pyproject = false;

  meta = {
    description = "Smart, quick launcher";
    homepage = "https://kupferlauncher.github.io/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ cobbal ];
    platforms = lib.platforms.linux;
  };
})
