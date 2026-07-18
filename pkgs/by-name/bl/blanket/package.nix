{
  lib,
  fetchFromGitHub,
  blueprint-compiler,
  desktop-file-utils,
  glib,
  gobject-introspection,
  gst_all_1,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "blanket";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "blanket";
    tag = finalAttrs.version;
    hash = "sha256-LnHL/1DJXiKx9U+JkT4Wjx1vtTmKLpzZ8q6uLT5a2MY=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  propagatedBuildInputs = with python3Packages; [ pygobject3 ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Listen to different sounds";
    homepage = "https://github.com/rafaelmardojai/blanket";
    changelog = "https://github.com/rafaelmardojai/blanket/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      onny
    ];

    platforms = lib.platforms.linux;
    mainProgram = "blanket";
    teams = [ lib.teams.gnome-circle ];
  };
})
