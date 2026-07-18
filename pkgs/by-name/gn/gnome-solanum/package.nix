{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  git,
  glib,
  gst_all_1,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "solanum";
  version = "6.0.0";

  src = fetchFromGitLab {
    owner = "World";
    repo = "Solanum";
    tag = finalAttrs.version;
    hash = "sha256-Wh9/88Vc4mtjL0U1Vrw+GEEBPjEv+5NrWd/Kw1glp+w=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    patchShebangs build-aux
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    python3
    git
    desktop-file-utils
    appstream-glib
    blueprint-compiler
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-krjbeutochFk5md+THlYBW4iEwfFDbK89DYHZyd3IKo=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Pomodoro timer for the GNOME desktop";
    homepage = "https://gitlab.gnome.org/World/Solanum";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ linsui ];
    platforms = lib.platforms.linux;
    mainProgram = "solanum";
    teams = [ lib.teams.gnome-circle ];
  };
})
