{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyevtk";
  version = "1.6.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-H2vnh2o6AFyCWIYVUdpP5+RP8aLn/yqT1txR3u39pfQ=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'setup_requires=["pytest-runner"],' 'setup_requires=[],'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "pyevtk" ];

  meta = {
    description = "Exports data to binary VTK files for visualization/analysis";
    homepage = "https://github.com/pyscience-projects/pyevtk";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
