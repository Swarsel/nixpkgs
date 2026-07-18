{
  lib,
  fetchFromGitLab,
  casilda,
  desktop-file-utils,
  glib,
  gobject-introspection,
  gtk3,
  gtk4,
  gtksourceview5,
  libadwaita,
  libhandy,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  shared-mime-info,
  webkitgtk_4_1,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "cambalache";
  version = "1.0";

  # Did not fetch submodule since it is only for tests we don't run.
  src = fetchFromGitLab {
    owner = "jpu";
    repo = "cambalache";
    tag = finalAttrs.version;
    hash = "sha256-V1xiw6oGOlmLR1JOy82REIdoOTGfzXYMBJAAtjDJtfM=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    patchShebangs postinstall.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection # for setup hook
    desktop-file-utils # for update-desktop-database
    shared-mime-info # for update-mime-database
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk3
    gtk4
    gtksourceview5
    webkitgtk_4_1
    webkitgtk_6_0
    # For extra widgets support.
    libadwaita
    libhandy
    libxml2
    casilda
  ];

  preFixup = ''
    # Let python wrapper use GNOME flags.
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    # Wrap a helper script in an unusual location.
    wrapPythonProgramsIn "$out/${python3.sitePackages}/cambalache/priv/merengue" "$out ''${pythonPath[*]}"
  '';

  # Prevent double wrapping.
  dontWrapGApps = true;
  pyproject = false;

  pythonPath = with python3.pkgs; [
    pygobject3
    lxml
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "RAD tool for GTK 4 and 3 with data model first philosophy";
    homepage = "https://gitlab.gnome.org/jpu/cambalache";

    license = with lib.licenses; [
      lgpl21Only # Cambalache
      gpl2Only # tools
    ];

    maintainers = with lib.maintainers; [ clerie ];
    platforms = lib.platforms.unix;
    mainProgram = "cambalache";
    teams = [ lib.teams.gnome ];
  };
})
