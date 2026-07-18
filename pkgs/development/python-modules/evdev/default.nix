{
  lib,
  buildPythonPackage,
  fetchPypi,
  linuxHeaders,
  setuptools,
}:

buildPythonPackage rec {
  pname = "evdev";
  version = "1.9.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-LBQOAayEN3WPoj/lyHE5dBJGH0LUIaogJB3I/oz8y8k=";
  };

  buildInputs = [ linuxHeaders ];
  doCheck = false;
  build-system = [ setuptools ];

  patchPhase = ''
    substituteInPlace setup.py \
      --replace-fail /usr/include ${linuxHeaders}/include
  '';

  pyproject = true;
  pythonImportsCheck = [ "evdev" ];

  meta = {
    description = "Provides bindings to the generic input event interface in Linux";
    homepage = "https://python-evdev.readthedocs.io/";
    changelog = "https://github.com/gvalkov/python-evdev/blob/v${version}/docs/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
