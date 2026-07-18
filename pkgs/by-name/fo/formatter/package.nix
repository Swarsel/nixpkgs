{
  lib,
  stdenv,
  fetchFromGitHub,
  dosfstools,
  e2fsprogs,
  exfat,
  glib,
  gtk3,
  hfsprogs,
  libgee,
  meson,
  ninja,
  nix-update-script,
  ntfs3g,
  pantheon,
  pkg-config,
  python3,
  replaceVars,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "formatter";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "Djaler";
    repo = "Formatter";
    rev = finalAttrs.version;
    sha256 = "sha256-8lZ0jUwHuc3Kntz73Btj6dJvkW2bvShu2KWTSQszbJo=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      exfat = "${exfat}/bin/mkfs.exfat";
      ext4 = "${e2fsprogs}/bin/mkfs.ext4";
      fat = "${dosfstools}/bin/mkfs.fat";
      hfsplus = "${hfsprogs}/bin/mkfs.hfsplus";
      ntfs = "${ntfs3g}/bin/mkfs.ntfs";
    })
  ];

  postPatch = ''
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    libgee
    pantheon.granite
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple formatter designed for elementary OS";
    homepage = "https://github.com/Djaler/Formatter";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ xiorcale ];
    platforms = lib.platforms.linux;
    mainProgram = "com.github.djaler.formatter";
    teams = [ lib.teams.pantheon ];
  };
})
