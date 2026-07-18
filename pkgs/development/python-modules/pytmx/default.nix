{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  pygame,
  pyglet,
  pysdl2,
  # tests
  pytestCheckHook,
  # build-system
  setuptools-scm,
}:

buildPythonPackage {
  pname = "pytmx";
  version = "3.32";

  src = fetchFromGitHub {
    owner = "bitcraft";
    repo = "PyTMX";
    # Latest release was not tagged. However, the changes of this commit - the
    # current HEAD - are part of the 3.32 release on PyPI.
    rev = "7af805bc916e666fdf7165d5d6ba4c0eddfcde18";
    hash = "sha256-zRrMk812gAZoCAeYq4Uz/1RwJ0lJc7szyZ3IQDYZOd4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;

  build-system = [
    setuptools-scm
  ];

  dependencies = [
    pygame
    pyglet
    pysdl2
  ];

  disabledTests = [
    # AssertionError on the property name
    "test_contains_reserved_property_name"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pytmx.pytmx"
    "pytmx.util_pygame"
    "pytmx.util_pyglet"
    "pytmx.util_pysdl2"
  ];

  meta = {
    description = "Python library to read Tiled Map Editor's TMX maps";
    homepage = "https://github.com/bitcraft/PyTMX";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
  };
}
