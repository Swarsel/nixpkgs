{
  lib,
  fetchFromGitLab,
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  gettext,
  gobject-introspection,
  jp2a,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "letterpress";
  version = "2.2";

  src = fetchFromGitLab {
    owner = "World";
    repo = "letterpress";
    rev = finalAttrs.version;
    hash = "sha256-cqLodI6UjdLCKLGGcSIbXu1+LOcq2DE00V+lVS7OBMg=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    appstream
    blueprint-compiler
    desktop-file-utils
    gettext
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  preFixup = ''
    makeWrapperArgs+=(''${gappsWrapperArgs[@]} --prefix PATH : ${lib.makeBinPath finalAttrs.runtimeDeps})
  '';

  dependencies = with python3Packages; [
    pillow
    pygobject3
  ];

  dontWrapGApps = true; # prevent double wrapping
  pyproject = false; # built by meson

  runtimeDeps = [
    jp2a
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Create beautiful ASCII art";

    longDescription = ''
      Letterpress converts your images into a picture made up of ASCII characters.
      You can save the output to a file, copy it, and even change its resolution!
      High-res output can still be viewed comfortably by lowering the zoom factor.
    '';

    homepage = "https://apps.gnome.org/Letterpress/";
    changelog = "https://gitlab.gnome.org/World/Letterpress/-/releases/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "letterpress";
    teams = [ lib.teams.gnome-circle ];
  };
})
