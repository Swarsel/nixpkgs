{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cloudscraper,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "epicstore-api";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "SD4RK";
    repo = "epicstore_api";
    tag = "v_${version}";
    hash = "sha256-XSynUz8rAl/+jcPMCZoVKlGZLVcTCAr36VEWVhAydoM=";
  };

  # tests directory exists but contains no test cases
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ cloudscraper ];
  pyproject = true;
  pythonImportsCheck = [ "epicstore_api" ];

  meta = {
    description = "Epic Games Store Web API Wrapper written in Python";
    homepage = "https://github.com/SD4RK/epicstore_api";
    changelog = "https://github.com/SD4RK/epicstore_api/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
