{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  h5py,
  hdf5plugin,
  lxml,
  meson,
  meson-python,
  ninja,
  numpy,
  pillow,
  tomli,
}:

buildPythonPackage rec {
  pname = "fabio";
  version = "2025.10.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wZdjvPoCp4pQfz2RS1ZKiZfIimqntPh/nbTOf6OX0lY=";
  };

  # While building, it tries to run version.py, which has a #!/usr/bin/env python3 shebang
  postPatch = ''
    patchShebangs --build version.py
  '';

  nativeBuildInputs = [
    meson
    cython
    meson-python
    ninja
  ];

  dependencies = [
    numpy
    lxml
    h5py
    hdf5plugin
    pillow
    tomli
  ];

  pyproject = true;
  pythonImportsCheck = [ "fabio" ];

  meta = {
    description = "I/O library for images produced by 2D X-ray detector";
    homepage = "https://github.com/silx-kit/fabio";
    changelog = "https://github.com/silx-kit/fabio/blob/main/doc/source/Changelog.rst";
    license = [ lib.licenses.mit ];
    maintainers = [ lib.maintainers.pmiddend ];
  };

}
