{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  gettext,
  glib,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  libgee,
  libxml2,
  meson,
  ninja,
  pantheon,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "regextester";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "artemanufrij";
    repo = "regextester";
    rev = finalAttrs.version;
    hash = "sha256-5+gU8DeB99w2h/4vMal2eHkR0305dmRYiY6fsLZzlnc=";
  };

  nativeBuildInputs = [
    vala
    gettext
    gobject-introspection
    libxml2
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    desktop-file-utils
  ];

  buildInputs = [
    pantheon.granite
    glib
    libgee
    gsettings-desktop-schemas
    gtk3
  ];

  postInstall = ''
    ${glib.dev}/bin/glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  meta = {
    description = "Desktop application to test regular expressions interactively";
    homepage = "https://github.com/artemanufrij/regextester";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ samdroid-apps ];
    platforms = lib.platforms.linux;
    mainProgram = "com.github.artemanufrij.regextester";
  };
})
