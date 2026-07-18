{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  gtk3,
  python3Packages,
  wrapGAppsHook3,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nwg-icon-picker";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-icon-picker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Gm3JhS6eq2mSex4VFe71tRf13qWDCSqXoiMvNIhu9Sw=";
  };

  postInstall = ''
    install -Dm444 -t $out/share/icons/hicolor/scalable/apps/ nwg-icon-picker.svg
    install -Dm444 -t $out/share/applications/ nwg-icon-picker.desktop
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    setuptools
    wrapGAppsHook3
    gobject-introspection
  ];

  dependencies = with python3Packages; [
    pygobject3
    gtk3
  ];

  # prevent double wrapped binary
  dontWrapGApps = true;
  pyproject = true;

  pythonImportsCheck = [
    "gi"
  ];

  meta = {
    description = "GTK icon chooser with a text search option";
    homepage = "https://github.com/nwg-piotr/nwg-icon-picker";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ quantenzitrone ];
    mainProgram = "nwg-icon-picker";
  };
})
