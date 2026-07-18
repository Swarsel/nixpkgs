{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  cmake,
  desktop-file-utils,
  gettext,
  glib,
  gtksourceview5,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snoop";
  version = "0.4.2";

  src = fetchFromGitLab {
    owner = "philippun1";
    repo = "snoop";
    tag = finalAttrs.version;
    hash = "sha256-M+wV6WYPtTbKXgBCOD/qN3LYAbpucwSAuKZQBVUjZo8=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    cmake
    gettext
    vala
    desktop-file-utils
    appstream-glib
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    libadwaita
    gtksourceview5
  ];

  patchPhase = ''
    runHook prePatch

    substituteInPlace build-aux/meson/postinstall.py \
      --replace-fail "/usr/bin/env python3" "${lib.getExe python3}"

    sed -i '/gtk-update-icon-cache/d' build-aux/meson/postinstall.py
    sed -i '/update-desktop-database/d' build-aux/meson/postinstall.py

    runHook postPatch
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Search through file contents in a given folder";
    homepage = "https://gitlab.gnome.org/philippun1/snoop";
    changelog = "https://gitlab.gnome.org/philippun1/snoop/-/releases/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
    mainProgram = "snoop";
  };
})
