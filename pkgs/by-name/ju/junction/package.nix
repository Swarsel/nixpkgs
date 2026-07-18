{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  gjs,
  gobject-introspection,
  gtk4,
  libadwaita,
  libportal-gtk4,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "junction";
  version = "1.12";

  src = fetchFromGitHub {
    owner = "sonnyp";
    repo = "junction";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sl/NeElAp/SWHp0BdXycrZYCgm4I4MFx/uHnQf78H8g=";
    fetchSubmodules = true;
  };

  postPatch = ''
    # gjs uses the invocation name to add gresource files
    # - https://gitlab.gnome.org/GNOME/gjs/-/blob/6aca7b50785fa1638f144b17060870d721e3f65a/modules/script/package.js#L159
    # - https://gitlab.gnome.org/GNOME/gjs/-/blob/6aca7b50785fa1638f144b17060870d721e3f65a/modules/script/package.js#L37
    # To work around this, we manually set the the name as done in foliate
    # - https://github.com/NixOS/nixpkgs/blob/3bacde6273b09a21a8ccfba15586fb165078fb62/pkgs/applications/office/foliate/default.nix#L23
    sed -i "1 a imports.package._findEffectiveEntryPointName = () => 're.sonny.Junction';" src/bin.js

    # /usr/bin/env is not accessible in build environment
    substituteInPlace troll/gjspack/bin/gjspack --replace "/usr/bin/env -S gjs" "${gjs}/bin/gjs"
  '';

  nativeBuildInputs = [
    appstream-glib
    blueprint-compiler
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gjs
    gtk4
    libadwaita
    libportal-gtk4
  ];

  postInstall = ''
    # autoPatchShebangs does not like "/usr/bin/env -S <environment-setting> gjs -m"
    sed -i "1s|.*|#!/usr/bin/gjs -m|" $out/bin/re.sonny.Junction
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Choose the application to open files and links";
    homepage = "https://apps.gnome.org/Junction/";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "re.sonny.Junction";
    teams = [ lib.teams.gnome-circle ];
  };
})
