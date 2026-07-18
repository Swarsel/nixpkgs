{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "asyncio-rlock";
  version = "0.1.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-fimCQzFhmHPhDV2Z3MRte48ZbEoRsgP07szAwJEDnUM=";
    pname = "asyncio_rlock";
  };

  # no tests on PyPI, no tags on GitLab
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "asyncio_rlock" ];

  meta = {
    description = "Rlock like in threading module but for asyncio";
    homepage = "https://gitlab.com/heckad/asyncio_rlock";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
