{
  lib,
  stdenv,
  fetchFromGitHub,
  gnome-settings-daemon,
  gtk4,
  meson,
  ninja,
  nix-update-script,
  pango,
  pantheon,
  pkg-config,
  sassc,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pantheon-tweaks";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "pantheon-tweaks";
    repo = "pantheon-tweaks";
    rev = finalAttrs.version;
    hash = "sha256-C6QgGjNjkgJ1qCNNe5gkwjzMfBosxjDIdVyIokCRkbE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    sassc
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    gnome-settings-daemon # org.gnome.settings-daemon.plugins.xsettings
    gtk4
    pango
  ]
  ++ (with pantheon; [
    elementary-files # io.elementary.files.preferences
    elementary-terminal # io.elementary.terminal.settings
    granite7
    switchboard
    wingpanel-indicator-sound # io.elementary.desktop.wingpanel.sound
  ]);

  mesonFlags = [
    "-Dsystheme_rootdir=/run/current-system/sw/share"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Unofficial system customization app for Pantheon";

    longDescription = ''
      Unofficial system customization app for Pantheon
      that lets you easily and safely customise your desktop's appearance.
    '';

    homepage = "https://github.com/pantheon-tweaks/pantheon-tweaks";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "pantheon-tweaks";
    teams = [ lib.teams.pantheon ];
  };
})
