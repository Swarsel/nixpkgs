{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  meson,
  ninja,
  pkg-config,
  systemd,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-session-ctl";
  version = "50.0";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "gnome-session-ctl";
    tag = finalAttrs.version;
    hash = "sha256-XKOWn6Yuyf5QXuvDfFEWL/ElfcL0s9mHsyuBwdIenLM=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    systemd
  ];

  meta = {
    description = "gnome-session-ctl extracted from gnome-session for nixpkgs";
    homepage = "https://github.com/nix-community/gnome-session-ctl";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})
