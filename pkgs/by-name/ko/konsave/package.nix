{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "konsave";
  version = "2.3.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-Qe+RZIsgbqvFqWhUkfACbYvHtXQcp6yK+XrvqgXnlTc=";
    pname = "konsave";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    pyyaml
    setuptools # pkg_resources is imported during runtime
  ];

  pyproject = true;
  pythonImportsCheck = [ "konsave" ];

  meta = {
    description = "Save Linux Customization";
    homepage = "https://github.com/Prayag2/konsave";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ MoritzBoehme ];
    platforms = lib.platforms.linux;
    mainProgram = "konsave";
  };
})
