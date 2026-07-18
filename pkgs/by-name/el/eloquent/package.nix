{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  blueprint-compiler,
  dbus,
  desktop-file-utils,
  gettext,
  gjs,
  glib,
  glib-networking,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk4,
  languagetool,
  libadwaita,
  libportal-gtk4,
  libsoup_3,
  meson,
  ninja,
  nix-update-script,
  openjdk,
  pkg-config,
  wrapGAppsHook4,
  xdg-desktop-portal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eloquent";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "sonnyp";
    repo = "Eloquent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wY/blD399GhEOdnQf/uVLHSmYUZTO1ZnL6+oOAhVqFA=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace troll/gjspack/bin/gjspack \
      --replace-fail "/usr/bin/env -S gjs" "${gjs}/bin/gjs"

    substituteInPlace src/languagetool.js \
      --replace-fail "/app/LanguageTool/languagetool-server.jar" "${languagetool}/share/languagetool-server.jar" \
      --replace-fail "--config" "" \
      --replace-fail "/app/share/server.properties" ""

    sed -i "1 a imports.package._findEffectiveEntryPointName = () => 're.sonny.Eloquent';" src/bin.js
    patchShebangs .
  '';

  strictDeps = true;

  nativeBuildInputs = [
    appstream
    blueprint-compiler
    desktop-file-utils
    gjs
    gobject-introspection
    libportal-gtk4
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    dbus
    gettext
    gjs
    glib
    glib-networking
    gsettings-desktop-schemas
    gtk4
    libadwaita
    libportal-gtk4
    libsoup_3
    xdg-desktop-portal
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --set JAVA_HOME ${openjdk}
      --prefix PATH : ${openjdk}/bin
    )
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Proofreading software for English, Spanish, French, German, and more than 20 other languages";
    homepage = "https://github.com/sonnyp/eloquent";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ thtrf ];
    platforms = lib.platforms.linux;
    mainProgram = "re.sonny.Eloquent";
  };
})
