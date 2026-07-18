{
  lib,
  stdenv,
  fetchFromGitLab,
  borgbackup,
  cargo,
  desktop-file-utils,
  git,
  gtk4,
  itstool,
  libadwaita,
  libsecret,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  python3,
  replaceVars,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "pika-backup";
  version = "0.8.3";

  src = fetchFromGitLab {
    owner = "World";
    repo = "pika-backup";
    tag = version;
    hash = "sha256-oM59t0oJzW7EyvcGoEwrokhxk+inxMLznf4Z2IEg3ig=";
    domain = "gitlab.gnome.org";
  };

  patches = [
    (replaceVars ./borg-path.patch {
      borg = lib.getExe borgbackup;
    })
  ];

  postPatch = ''
    patchShebangs build-aux
  '';

  nativeBuildInputs = [
    desktop-file-utils
    git
    itstool
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    gtk4
    libadwaita
    libsecret
    openssl
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-CWyZYnurIWiGzfUpa7OgmLU/CVRiAGbgFM0+frRfi9c=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple backups based on borg";
    homepage = "https://apps.gnome.org/app/org.gnome.World.PikaBackup";
    changelog = "https://gitlab.gnome.org/World/pika-backup/-/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome-circle ];
  };
}
