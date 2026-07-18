{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  meson-python,
  pkg-config,
  # Reverse dependency
  sage,
}:

buildPythonPackage rec {
  pname = "memory-allocator";
  version = "0.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Z108kQGduYyXRB3nPVxkiCHlroE/P1TNCYY9R0tI/iY=";
    pname = "memory_allocator";
  };

  nativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = [ cython ];

  build-system = [
    meson-python
    cython
  ];

  pyproject = true;
  pythonImportsCheck = [ "memory_allocator" ];

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Extension class to allocate memory easily with cython";
    homepage = "https://github.com/sagemath/memory_allocator/";
    license = lib.licenses.lgpl3Plus;
    teams = [ lib.teams.sage ];
  };
}
