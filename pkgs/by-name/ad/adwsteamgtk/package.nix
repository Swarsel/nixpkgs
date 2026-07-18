{
  lib,
  fetchFromGitHub,
  blueprint-compiler,
  desktop-file-utils,
  libadwaita,
  libportal-gtk4,
  meson,
  ninja,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "adwsteamgtk";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "Foldex";
    repo = "AdwSteamGtk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n+BNqa+SHB1V1INHooc0VpeqZ2Dy1Byt7mrbJc2MXts=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    meson
    ninja
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    libportal-gtk4
  ];

  propagatedBuildInputs = with python3Packages; [
    packaging
    pygobject3
  ];

  # built with meson, not a python format
  pyproject = false;

  meta = {
    description = "Simple Gtk wrapper for Adwaita-for-Steam";
    homepage = "https://github.com/Foldex/AdwSteamGtk";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ reedrw ];
    platforms = lib.platforms.linux;
    mainProgram = "adwaita-steam-gtk";
  };
})
