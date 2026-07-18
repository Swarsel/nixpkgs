{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  autoAddDriverRunpath,
  cargo,
  desktop-file-utils,
  dmidecode,
  glib,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
  systemd,
  util-linux,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "resources";
  version = "1.10.2";

  src = fetchFromGitHub {
    owner = "nokyan";
    repo = "resources";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BkyWq3Cwt34lNQ/p1iQcfIlkCefE2YeiQMd1T6ODbxw=";
  };

  nativeBuildInputs = [
    appstream-glib
    autoAddDriverRunpath
    desktop-file-utils
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  mesonFlags = [
    (lib.mesonOption "profile" "default")
  ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : ${lib.makeBinPath finalAttrs.runtimeDeps})
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-zzSqwc+MoYoieOT0qmgfxKG8/HLGTVsTgcru5wZgn2M=";
  };

  # Check all Command::new
  runtimeDeps = [
    dmidecode
    util-linux # lscpu
    systemd # udevadm
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Monitor your system resources and processes";
    homepage = "https://github.com/nokyan/resources";
    changelog = "https://github.com/nokyan/resources/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      lukas-heiligenbrunner
      ewuuwe
      graysontinker
    ];

    platforms = lib.platforms.linux;
    mainProgram = "resources";
    teams = [ lib.teams.gnome-circle ];
  };
})
