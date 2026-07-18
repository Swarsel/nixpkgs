{
  lib,
  fetchFromGitHub,
  desktop-file-utils,
  glib,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  python3,
  wl-clipboard,
  wrapGAppsHook4,
  xdotool,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "smile";
  version = "2.12.3";

  src = fetchFromGitHub {
    owner = "mijorus";
    repo = "smile";
    tag = finalAttrs.version;
    hash = "sha256-/VRo31FUDKGE5xZHNLTJ++1fYodWPhTxPUPf9Ya6fMU=";
  };

  nativeBuildInputs = [
    desktop-file-utils # for update-desktop-database
    glib # for glib-compile-resources
    gobject-introspection
    meson
    ninja
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix PATH : ${
        lib.makeBinPath [
          xdotool
          wl-clipboard
        ]
      }
    )
  '';

  dependencies = with python3.pkgs; [
    dbus-python
    manimpango
    pygobject3
  ];

  dontWrapGApps = true;
  pyproject = false; # Builds with meson

  meta = {
    description = "Emoji picker for linux, with custom tags support and localization";
    homepage = "https://mijorus.it/projects/smile/";
    changelog = "https://smile.mijorus.it/changelog";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      koppor
      aleksana
    ];

    mainProgram = "smile";
    downloadPage = "https://github.com/mijorus/smile";
  };
})
