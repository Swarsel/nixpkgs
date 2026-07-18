{
  lib,
  fetchFromGitHub,
  appstream,
  blueprint-compiler,
  cmake,
  desktop-file-utils,
  gettext,
  glib,
  gtk4,
  libGL,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cine";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "diegopvlk";
    repo = "Cine";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WBzdBZ7WL6HAd26tJtTaw39jAtdNYNiNmYHhVr+JBtM=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
    wrapGAppsHook4
    blueprint-compiler
    desktop-file-utils
    appstream
  ];

  buildInputs = [
    gettext
    glib
    gtk4
    libadwaita
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    makeWrapperArgs+=(--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL ]})
  '';

  dependencies = with python3Packages; [
    pygobject3
    mpv
  ];

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Video Player for Linux";
    homepage = "https://github.com/diegopvlk/Cine";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ pancaek ];
    platforms = lib.platforms.linux;
    mainProgram = "cine";
  };
})
