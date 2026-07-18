{
  lib,
  fetchFromGitHub,
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  gettext,
  glib,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ticketbooth";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "aleiepure";
    repo = "ticketbooth";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eP5wYNusBcQLMu4MljfcO9QLY74v5Sb8gITx5dDVLpM=";
  };

  nativeBuildInputs = [
    appstream # for appstreamcli
    blueprint-compiler
    desktop-file-utils # for desktop-file-validate
    gettext # for msgfmt
    glib # for glib-compile-schemas
    gtk4 # for gtk4-update-icon-cache
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  mesonFlags = [
    (lib.mesonBool "prerelease" false)
  ];

  dependencies = with python3Packages; [
    pillow
    pygobject3
    tmdbsimple
  ];

  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Keep track of your favorite shows";
    homepage = "https://github.com/aleiepure/ticketbooth";
    changelog = "https://github.com/aleiepure/ticketbooth/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.dotlambda ];
    platforms = lib.platforms.linux;
    mainProgram = "ticketbooth";
  };
})
