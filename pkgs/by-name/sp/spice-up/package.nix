{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  gtk3,
  json-glib,
  libevdev,
  libgee,
  libgudev,
  meson,
  ninja,
  nix-update-script,
  pantheon,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spice-up";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "Philip-Scott";
    repo = "Spice-up";
    tag = finalAttrs.version;
    hash = "sha256-FI6YMbqZfaU19k8pS2eoNCnX8O8F99SHHOxMwHC5fTc=";
  };

  # Drop dependency on libsoup 2.4, which is insecure. It's no longer actually
  # used upstream, so this is harmless.
  # https://github.com/Philip-Scott/Spice-up/issues/328
  postPatch = ''
    substituteInPlace meson.build --replace-fail "soup_dep = dependency('libsoup-2.4')" ""
    substituteInPlace src/meson.build --replace-fail "soup_dep," ""

    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    json-glib
    libevdev
    libgee
    libgudev
    pantheon.granite
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Create simple and beautiful presentations";
    homepage = "https://github.com/Philip-Scott/Spice-up";
    # The COPYING file has GPLv3; some files have GPLv2+ and some have GPLv3+
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      samdroid-apps
      xiorcale
    ];

    platforms = lib.platforms.linux;
    mainProgram = "com.github.philip_scott.spice-up";
    teams = [ lib.teams.pantheon ];
  };
})
