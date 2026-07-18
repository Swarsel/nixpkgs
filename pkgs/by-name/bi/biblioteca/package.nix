{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  coreutils,
  desktop-file-utils,
  gjs,
  glib,
  glib-networking,
  gobject-introspection,
  gtk4,
  libadwaita,
  makeShellWrapper,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  symlinkJoin,
  webkitgtk_6_0,
  wrapGAppsHook4,
  extraDocsPackage ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "biblioteca";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "workbenchdev";
    repo = "Biblioteca";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PRm/4t0f8AExOFXCcV7S+JIKkJgYP1gego2xTUbj7FY=";
    fetchSubmodules = true;
  };

  patches = [
    ./dont-use-flatpak.patch # From https://gitlab.archlinux.org/archlinux/packaging/packages/biblioteca/-/blob/main/biblioteca-no-flatpak.patch?ref_type=heads
  ];

  postPatch = ''
    patchShebangs .

    substituteInPlace build-aux/build-index.js \
      --replace-fail "/usr/bin/env -S gjs -m" "${coreutils}/bin/env -S ${gjs}/bin/gjs -m" \
      --replace-fail "/app/share/doc" "${finalAttrs.docPath}/share/doc"

    substituteInPlace src/Shortcuts.js \
      --replace-fail "/app/share/doc" "${finalAttrs.docPath}/share/doc"
    substituteInPlace src/window.blp \
      --replace-fail "/app/share/doc" "${finalAttrs.docPath}/share/doc"
    substituteInPlace src/window.js \
      --replace-fail "/app/share/doc" "${finalAttrs.docPath}/share/doc"
  '';

  nativeBuildInputs = [
    meson
    ninja
    blueprint-compiler
    desktop-file-utils
    makeShellWrapper
    gjs
    wrapGAppsHook4
    pkg-config
  ];

  buildInputs = [
    glib
    gtk4
    gobject-introspection
    libadwaita
    webkitgtk_6_0
    glib-networking
  ];

  doCheck = true;

  postInstall = ''
    mv $out/bin/app.drey.Biblioteca $out/share/app.drey.Biblioteca/app.drey.Biblioteca
    substituteInPlace $out/bin/biblioteca \
      --replace-fail app.drey.Biblioteca $out/share/app.drey.Biblioteca/app.drey.Biblioteca
  '';

  docPath = symlinkJoin {
    name = "biblioteca-docs";

    paths = [
      gtk4.devdoc
      glib.devdoc
      libadwaita.devdoc
      webkitgtk_6_0.devdoc
      gobject-introspection.devdoc
    ]
    ++ extraDocsPackage;
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Documentation viewer for GNOME";
    homepage = "https://apps.gnome.org/Biblioteca/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.linux;
    mainProgram = "biblioteca";
    teams = [ lib.teams.gnome-circle ];
  };
})
