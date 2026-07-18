{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  # dependencies
  pandas,
  # tests
  pytestCheckHook,
  pyyaml,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "mhcgnomes";
  version = "3.32.1";

  src = fetchFromGitHub {
    owner = "pirl-unc";
    repo = "mhcgnomes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6YYmIXuZXCaozkrVhqlxSQ9TG7vthHcMhVl0QpWChZE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    pandas
    pyyaml
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "mhcgnomes" ];

  meta = {
    description = "Parsing MHC nomenclature in the wild";
    homepage = "https://github.com/pirl-unc/mhcgnomes";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ samuela ];
  };
})
