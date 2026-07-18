{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dbus-next,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "clipman";
  version = "3.3.3";

  src = fetchFromGitHub {
    owner = "NikitaBeloglazov";
    repo = "clipman";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m50yxbbMBLooVQD1QYQi6QekaiQlzTHXSJIMdU+/+Rw=";
  };

  buildInputs = [
    dbus-next
  ];

  # no tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "clipman"
  ];

  meta = {
    description = "Python3 module for working with clipboard";
    homepage = "https://github.com/NikitaBeloglazov/clipman";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ Freed-Wu ];
    platforms = lib.platforms.unix;
  };
})
