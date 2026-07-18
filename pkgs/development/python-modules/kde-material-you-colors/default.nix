{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dbus-python,
  materialyoucolor,
  numpy,
  pillow,
  python-magic,
  pywal16,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "kde-material-you-colors";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "luisbocanegra";
    repo = "kde-material-you-colors";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sN7u3jePevJnTHhQL6eAYKU2AD2QNW7VYuEHLN5RsK8=";
  };

  doCheck = false; # no unittests, and would require KDE desktop environment
  build-system = [ setuptools ];

  dependencies = [
    dbus-python
    numpy
    pillow
    materialyoucolor
    python-magic
    pywal16
  ];

  pyproject = true;
  pythonImportsCheck = [ "kde_material_you_colors" ];

  meta = {
    description = "Automatic color scheme generator from your wallpaper for KDE Plasma powered by Material You";
    homepage = "https://store.kde.org/p/2136963";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ issai ];
    mainProgram = "kde-material-you-colors";
  };
})
