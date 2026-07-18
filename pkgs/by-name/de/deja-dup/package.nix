{
  lib,
  stdenv,
  fetchFromGitLab,
  blueprint-compiler,
  borgbackup,
  desktop-file-utils,
  duplicity,
  gettext,
  glib,
  glib-networking,
  gtk4,
  itstool,
  json-glib,
  libadwaita,
  libgpg-error,
  libsecret,
  libsoup_3,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rclone,
  restic,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deja-dup";
  version = "50.1";

  src = fetchFromGitLab {
    owner = "World";
    repo = "deja-dup";
    tag = finalAttrs.version;
    hash = "sha256-c4Myy1nV6CupGG53Iqm0Z82yVx/Llgot4IZCrnubacE=";
    domain = "gitlab.gnome.org";
  };

  patches = [ ./find-fusermount-setuid.patch ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    gettext
    itstool
    blueprint-compiler
    desktop-file-utils
    wrapGAppsHook4
  ];

  buildInputs = [
    libsoup_3
    glib
    glib-networking
    gtk4
    libsecret
    libadwaita
    libgpg-error
    json-glib
  ];

  mesonFlags = [
    # Check https://gitlab.gnome.org/World/deja-dup/-/blob/main/meson.options
    (lib.mesonOption "borg_command" (lib.getExe borgbackup))
    (lib.mesonOption "duplicity_command" (lib.getExe duplicity))
    (lib.mesonOption "rclone_command" (lib.getExe rclone))
    (lib.mesonOption "restic_command" (lib.getExe restic))
    (lib.mesonEnable "packagekit" false) # packagekit-glib not packaged
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      # Required by duplicity
      --prefix PATH : "${lib.makeBinPath [ rclone ]}"
    )
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple backup tool";

    longDescription = ''
      Déjà Dup is a simple backup tool. It hides the complexity
      of backing up the Right Way (encrypted, off-site, and regular)
      and uses duplicity as the backend.
    '';

    homepage = "https://apps.gnome.org/DejaDup/";
    changelog = "https://gitlab.gnome.org/World/deja-dup/-/releases/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.linux;
    mainProgram = "deja-dup";
    teams = [ lib.teams.gnome-circle ];
  };
})
