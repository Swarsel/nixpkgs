{
  lib,
  stdenv,
  fetchFromGitLab,
  desktop-file-utils,
  gtk4,
  json-glib,
  libadwaita,
  libgee,
  librsvg,
  libxml2,
  meson,
  ninja,
  pcre2,
  pkg-config,
  python3,
  sassc,
  vala,
  vte-gtk4,
  wrapGAppsHook4,
}:

stdenv.mkDerivation {
  pname = "blackbox-terminal";
  version = "0.14.0-unstable-2025-08-29";

  src = fetchFromGitLab {
    owner = "raggesilver";
    repo = "blackbox";
    rev = "9290c2feddc4415752afd1b03c82a1d82a6b3392";
    hash = "sha256-s1e9zS4ijsa3+zxlsdxlqTzR1Rnb4hxjwlqYEhtvy5g=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    substituteInPlace build-aux/meson/postinstall.py \
      --replace-fail 'gtk-update-icon-cache' 'gtk4-update-icon-cache'
    patchShebangs build-aux/meson/postinstall.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    sassc
    wrapGAppsHook4
    python3
    desktop-file-utils # For update-desktop-database
  ];

  buildInputs = [
    gtk4
    vte-gtk4
    json-glib
    libadwaita
    pcre2
    libxml2
    librsvg
    libgee
  ];

  mesonFlags = [
    (lib.mesonBool "blackbox_is_flatpak" false)
  ];

  meta = {
    description = "Elegant and customizable terminal for GNOME";
    homepage = "https://gitlab.gnome.org/raggesilver/blackbox";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      chuangzhu
    ];

    platforms = lib.platforms.linux;
    mainProgram = "blackbox";
  };
}
