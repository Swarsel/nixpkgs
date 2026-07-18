{
  lib,
  fetchurl,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
  glib,
  gnome,
  gnome-desktop,
  gnome-settings-daemon,
  gnome-shell,
  gnome-shell-extensions,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk4,
  itstool,
  libadwaita,
  libgudev,
  libnotify,
  libxml2,
  meson,
  mutter,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gnome-tweaks";
  version = "49.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-tweaks/${lib.versions.major finalAttrs.version}/gnome-tweaks-${finalAttrs.version}.tar.xz";
    hash = "sha256-s5Cb3LSQW2hCfWq1geAfQ23/jlwKOJseCxRQDxiAbrs=";
  };

  postPatch = ''
    patchShebangs meson-postinstall.py
  '';

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    gobject-introspection
    itstool
    libxml2
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gnome-desktop
    gnome-settings-daemon
    gnome-shell
    # Makes it possible to select user themes through the `user-theme` extension
    gnome-shell-extensions
    mutter
    gsettings-desktop-schemas
    gtk4
    libadwaita
    libgudev
    libnotify
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    wrapPythonProgramsIn "$out/libexec" "$out ''${pythonPath[*]}"
  '';

  dontWrapGApps = true;
  pyproject = false;

  pythonPath = with python3Packages; [
    pygobject3
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-tweaks";
    };
  };

  meta = {
    description = "Tool to customize advanced GNOME 3 options";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-tweaks";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-tweaks";
    teams = [ lib.teams.gnome ];
  };
})
