{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "smarthab";
  version = "0.21";

  src = fetchPypi {
    inherit version;
    hash = "sha256-v5KUVaL3zB4nWzMd5z2YNYcTio2ReVdJiLoF+hUtPM8=";
    pname = "SmartHab";
  };

  # no tests on PyPI, no tags on GitLab
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pysmarthab" ];

  meta = {
    description = "Control devices in a SmartHab-powered home";
    homepage = "https://gitlab.com/outadoc/python-smarthab";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
