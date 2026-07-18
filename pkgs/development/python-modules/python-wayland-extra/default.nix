{
  lib,
  black,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  lxml,
  pytest,
  requests,
  ruff,
}:

buildPythonPackage rec {
  pname = "python-wayland-extra";
  version = "0.7.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-HSBOCWP3o/BHmg3LO+LU+GpYkEYSqdljjYcEPdOnxZk=";
    pname = "python_wayland_extra";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', "black", "lxml", "requests", "pytest", "ruff"' ""
  '';

  # requires working wayland display
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    lxml
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "wayland" ];

  meta = {
    description = "Implementation of the Wayland protocol with no external dependencies";
    homepage = "https://github.com/dennisrijsdijk/python-wayland-extra";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sifmelcara ];
    platforms = lib.platforms.linux;
  };
}
