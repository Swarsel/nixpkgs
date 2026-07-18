{
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  gobject-introspection,
  gtk4,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "conjure";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "nate-xyz";
    repo = "conjure";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qWeqUQxTTnmJt40Jm1qDTGGuSQikkurzOux8sZsmDQk=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
    appstream-glib
    meson
    ninja
    pkg-config
    gtk4
  ];

  buildInputs = [
    libadwaita
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    loguru
    wand
  ];

  nativeCheckInputs = with python3Packages; [
    pytest
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Magically transform your images";

    longDescription = ''
      Resize, crop, rotate, flip images, apply various filters and effects,
      adjust levels and brightness, and much more. An intuitive tool for designers,
      artists, or just someone who wants to enhance their images.
      Built on top of the popular image processing library, ImageMagick with python
      bindings from Wand.
    '';

    homepage = "https://github.com/nate-xyz/conjure";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ sund3RRR ];
    mainProgram = "conjure";
  };
})
