{
  lib,
  fetchFromGitLab,
  blueprint-compiler,
  desktop-file-utils,
  ffmpeg,
  glycin-loaders,
  gobject-introspection,
  gst-thumbnailers,
  libadwaita,
  libglycin,
  libglycin-gtk4,
  libva-utils,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "constrict";
  version = "26.2";

  src = fetchFromGitLab {
    owner = "World";
    repo = "Constrict";
    tag = finalAttrs.version;
    hash = "sha256-SkfutiBi0Y7gNx5PyTaSzVw/5rU/0ULxbtf2606i2wA=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    blueprint-compiler
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
    libglycin
    libglycin-gtk4
    glycin-loaders
  ];

  preFixup = ''
    makeWrapperArgs+=(
      ''${gappsWrapperArgs[@]}
      --prefix PATH : ${lib.makeBinPath finalAttrs.runtimeDeps}
    )
  '';

  dependencies = [
    python3Packages.pygobject3
  ];

  dontWrapGApps = true;
  pyproject = false; # Built with meson

  # Search for use of subprocess
  runtimeDeps = [
    libva-utils
    ffmpeg
    gst-thumbnailers
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Compresses your videos to your chosen file size";
    homepage = "https://gitlab.gnome.org/World/Constrict";
    changelog = "https://gitlab.gnome.org/World/Constrict/-/releases/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "constrict";
    teams = [ lib.teams.gnome-circle ];
  };
})
