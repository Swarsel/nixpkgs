{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  at-spi2-atk,
  at-spi2-core,
  dbus,
  desktop-file-utils,
  glib,
  gtk3,
  ibus,
  json-glib,
  libgee,
  libxtst,
  meson,
  ninja,
  nix-update-script,
  pantheon,
  pkg-config,
  python3,
  sqlite,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snippetpixie";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "bytepixie";
    repo = "snippetpixie";
    rev = finalAttrs.version;
    sha256 = "0gs3d9hdywg4vcfbp4qfcagfjqalfgw9xpvywg4pw1cm3rzbdqmz";
  };

  postPatch = ''
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    wrapGAppsHook3
    appstream
    desktop-file-utils
    python3
  ];

  buildInputs = [
    libgee
    glib
    gtk3
    sqlite
    at-spi2-atk
    at-spi2-core
    dbus
    ibus
    json-glib
    libxtst
    pantheon.granite
  ];

  doCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Your little expandable text snippet helper";

    longDescription = ''
      Your little expandable text snippet helper.

      Save your often used text snippets and then expand them whenever you type their abbreviation.

      For example:- "spr`" expands to "Snippet Pixie rules!"

      For non-accessible applications such as browsers and Electron apps, there's a shortcut (default is Ctrl+`) for opening a search window that pastes the selected snippet.
    '';

    homepage = "https://www.snippetpixie.com";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "com.github.bytepixie.snippetpixie";
    teams = [ lib.teams.pantheon ];
  };
})
