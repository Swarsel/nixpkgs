{
  lib,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  glib,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "halftone";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "tfuxu";
    repo = "halftone";
    tag = finalAttrs.version;
    hash = "sha256-5hT6ulmUlOrFVL4nV0tfvgkKdYGusp+1rBINQy3ZvpI=";
  };

  nativeBuildInputs = [
    appstream-glib
    blueprint-compiler
    desktop-file-utils
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    glib
    gobject-introspection
  ];

  buildInputs = [
    libadwaita
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    wand
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Simple app for giving images that pixel-art style";
    homepage = "https://github.com/tfuxu/halftone";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "halftone";
  };
})
