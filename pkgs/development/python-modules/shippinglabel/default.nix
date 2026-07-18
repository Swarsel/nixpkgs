{
  lib,
  buildPythonPackage,
  dist-meta,
  dom-toml,
  domdf-python-tools,
  fetchPypi,
  hatch-requirements-txt,
  hatchling,
  packaging,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "shippinglabel";
  version = "2.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JcDDGUwBHANV3/j1bMCzFoj2k7IJ9YSdRJkdii7JHy8=";
  };

  build-system = [
    hatchling
    hatch-requirements-txt
  ];

  dependencies = [
    dist-meta
    dom-toml
    domdf-python-tools
    packaging
    typing-extensions
  ];

  pyproject = true;

  meta = {
    description = "Utilities for handling packages";
    homepage = "https://github.com/domdfcoding/shippinglabel";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tyberius-prime ];
  };
}
