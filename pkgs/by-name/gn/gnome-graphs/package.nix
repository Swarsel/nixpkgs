{
  lib,
  fetchFromGitLab,
  blueprint-compiler,
  desktop-file-utils,
  gobject-introspection,
  itstool,
  libadwaita,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  shared-mime-info,
  vala,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gnome-graphs";
  version = "1.8.8";

  src = fetchFromGitLab {
    owner = "World";
    repo = "Graphs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XsdrXdIZmAngS52KmjcNbOWwYJsnhNGELSd0p3h/XWE=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    gobject-introspection
    blueprint-compiler
    itstool
    wrapGAppsHook4
    desktop-file-utils
    shared-mime-info
  ];

  buildInputs = [
    libadwaita
    libgee
  ];

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix LD_LIBRARY_PATH : $out/lib
    )
  '';

  dependencies = with python3Packages; [
    pygobject3
    numpy
    numexpr
    sympy
    scipy
    matplotlib
  ];

  dontWrapGApps = true;
  pyproject = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple, yet powerful tool that allows you to plot and manipulate your data with ease";
    homepage = "https://apps.gnome.org/Graphs";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux; # locale.bindtextdomain only available on linux
    mainProgram = "graphs";
    teams = [ lib.teams.gnome-circle ];
  };
})
