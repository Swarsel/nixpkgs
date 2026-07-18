{
  lib,
  boost-histogram,
  buildPythonPackage,
  fastjsonschema,
  fetchPypi,
  h5py,
  hatch-vcs,
  hatchling,
  hist,
  numpy,
  packaging,
  pytestCheckHook,
  pythonOlder,
  tomli,
  typing-extensions,
  uhi,
}:

buildPythonPackage rec {
  pname = "uhi";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-MxGIlJsaScjbnvnVC3xNTfRgYRXRR97ZfE8FDagnDnQ=";
  };

  doCheck = false; # Prevents infinite recursion; use passthru.tests instead

  nativeCheckInputs = [
    boost-histogram
    hist
    fastjsonschema
    packaging
    pytestCheckHook
  ]
  ++ lib.optionals (pythonOlder "3.11") [ tomli ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    numpy
  ]
  ++ lib.optionals (pythonOlder "3.11") [
    typing-extensions
  ];

  optional-dependencies = {
    hdf5 = [ h5py ];
    schema = [ fastjsonschema ];
  };

  pyproject = true;
  passthru.tests.uhi = uhi.overridePythonAttrs { doCheck = true; };

  meta = {
    description = "Universal Histogram Interface";
    homepage = "https://uhi.readthedocs.io/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ veprbl ];
  };
}
