{
  lib,
  fetchurl,
  at-spi2-core,
  desktop-file-utils,
  gettext,
  gnome,
  gobject-introspection,
  gtk3,
  itstool,
  librsvg,
  libwnck,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "accerciser";
  version = "3.48.0";

  src = fetchurl {
    url = "mirror://gnome/sources/accerciser/${lib.versions.majorMinor finalAttrs.version}/accerciser-${finalAttrs.version}.tar.xz";
    hash = "sha256-kCiOiQCidKOu4gUw6zkWRZlK6YZyIJFroPXEZ3v+n00=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    gobject-introspection # For setup hook
    itstool
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    at-spi2-core
    gtk3
    libwnck
    librsvg
  ];

  propagatedBuildInputs = with python3.pkgs; [
    dbus-python
    ipython
    pyatspi
    pycairo
    pygobject3
    pyxdg
    setuptools # for pkg_resources
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "accerciser";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Interactive Python accessibility explorer";
    homepage = "https://gitlab.gnome.org/GNOME/accerciser";
    changelog = "https://gitlab.gnome.org/GNOME/accerciser/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "accerciser";
    teams = [ lib.teams.gnome ];
  };
})
