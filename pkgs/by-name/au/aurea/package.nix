{
  lib,
  fetchFromGitHub,
  blueprint-compiler,
  desktop-file-utils,
  glib-networking,
  libadwaita,
  libsoup_3,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "aurea";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "CleoMenezesJr";
    repo = "Aurea";
    tag = finalAttrs.version;
    hash = "sha256-XoLqtuh4ZIeKo8xb1ccaK+9K3uGuQfZt9Fb6NeUDCjE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    blueprint-compiler
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
    libsoup_3
    glib-networking
  ];

  dependencies = with python3Packages; [
    pygobject3
    pillow
  ];

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];

  postInstallCheck = ''
    mesonCheckPhase
  '';

  pyproject = false; # uses meson
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Flatpak metainfo banner previewer";
    homepage = "https://github.com/CleoMenezesJr/Aurea";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "aurea";
  };
})
