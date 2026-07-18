{
  lib,
  fetchFromGitHub,
  cinnamon-gsettings-overrides,
  desktop-file-utils,
  glib,
  gnome,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  mate-desktop,
  mate-settings-daemon,
  meson,
  ninja,
  pkg-config,
  python3,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "themechanger";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "ALEX11BR";
    repo = "ThemeChanger";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+uTofigS1F/nBNs/OyJ+RSz10DNnqgvNjWpkTXAvARM=";
  };

  postPatch = ''
    patchShebangs postinstall.py
  '';

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    desktop-file-utils
    gtk3
  ];

  buildInputs = [
    cinnamon-gsettings-overrides
    glib
    gnome.nixos-gsettings-overrides
    gtk3
    mate-desktop
    mate-settings-daemon
    python3
    gsettings-desktop-schemas
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  pyproject = false;

  meta = {
    description = "Theme changing utility for Linux";

    longDescription = ''
      This app is a theme changing utility for Linux, BSDs, and whatnots.
      It lets the user change GTK 2/3/4, Kvantum, icon and cursor themes, edit GTK CSS with live preview, and set some related options.
      It also lets the user install icon and widget theme archives.
    '';

    homepage = "https://github.com/ALEX11BR/ThemeChanger";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ALEX11BR ];
    platforms = lib.platforms.linux;
    mainProgram = "themechanger";
  };
})
