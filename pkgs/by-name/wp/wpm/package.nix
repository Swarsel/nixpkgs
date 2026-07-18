{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "wpm";
  version = "1.51.5";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-swT9E5Tto4yWnm0voowcJXtY3cIY3MNqAdfrTnuGbdg=";
  };

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    setuptools # pkg_resources is imported during runtime
  ];

  pyproject = true;
  pythonImportsCheck = [ "wpm" ];

  meta = {
    description = "Console app for measuring typing speed in words per minute (WPM)";
    homepage = "https://pypi.org/project/wpm";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ alejandrosame ];
    mainProgram = "wpm";
  };
})
