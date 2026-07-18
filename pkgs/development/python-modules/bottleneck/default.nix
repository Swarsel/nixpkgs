{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pytestCheckHook,
  python,
  setuptools,
  versioneer,
}:

buildPythonPackage (finalAttrs: {
  pname = "bottleneck";
  version = "1.6.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Ao1G7ksCWtmrTXmSQROBb4JfYrF7h8nh0NjOFEpKDjE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  preCheck = "pushd $out";
  postCheck = "popd";
  __structuredAttrs = true;

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "bottleneck" ];

  meta = {
    description = "Fast NumPy array functions";
    homepage = "https://github.com/pydata/bottleneck";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
})
