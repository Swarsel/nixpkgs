{
  lib,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  glib,
  gtk4,
  libadwaita,
  librsvg,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "dynamic-wallpaper";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "dusansimic";
    repo = "dynamic-wallpaper";
    rev = finalAttrs.version;
    hash = "sha256-DAdx34EYO8ysQzbWrAIPoghhibwFtoqCi8oyDVyO5lk=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    blueprint-compiler
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    librsvg
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  # Prevent double wrapping
  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Dynamic wallpaper maker for Gnome";
    homepage = "https://github.com/dusansimic/dynamic-wallpaper";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.linux;
    mainProgram = "me.dusansimic.DynamicWallpaper";
  };
})
