{
  lib,
  fetchFromGitLab,
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  glib,
  gtk4,
  libadwaita,
  libportal,
  libportal-gtk4,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "refine";
  version = "0.7.0";

  src = fetchFromGitLab {
    owner = "TheEvilSkeleton";
    repo = "Refine";
    tag = finalAttrs.version;
    hash = "sha256-5rHct0GXsdjeG+wXxtDKXWBTCphhOCojuR2ExXrZyWA=";
    domain = "gitlab.gnome.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    appstream
    blueprint-compiler
    glib # For `glib-compile-schemas`
    gtk4 # For `gtk-update-icon-cache`
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    python3
    desktop-file-utils
  ];

  buildInputs = [
    libxml2
    libadwaita
  ];

  mesonFlags = [ (lib.mesonBool "network_tests" false) ];

  dependencies = [
    libportal
    libportal-gtk4
  ]
  ++ (with python3Packages; [
    pygobject3
  ]);

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];

  # NOTE: `postCheck` is intentionally not used here, as the entire checkPhase
  # is skipped by `buildPythonApplication`
  # https://github.com/NixOS/nixpkgs/blob/9d4343b7b27a3e6f08fc22ead568233ff24bbbde/pkgs/development/interpreters/python/mk-python-derivation.nix#L296
  postInstallCheck = ''
    mesonCheckPhase
  '';

  pyproject = false; # uses meson
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tweak various aspects of GNOME";
    homepage = "https://gitlab.gnome.org/TheEvilSkeleton/Refine";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ getchoo ];
    platforms = lib.platforms.linux;
    mainProgram = "refine";
  };
})
