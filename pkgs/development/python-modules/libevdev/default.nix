{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  pkgs,
  pytestCheckHook,
  replaceVars,
}:

buildPythonPackage rec {
  pname = "libevdev";
  version = "0.13.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3DNpzRQBdnueyxEXzWtz+rqQOOO9nhaVpxCp6dlBXo0=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      libevdev = lib.getLib pkgs.libevdev;
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;

  meta = {
    description = "Python wrapper around the libevdev C library";
    homepage = "https://gitlab.freedesktop.org/libevdev/python-libevdev";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickhu ];
  };
}
