{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  python-dateutil,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "srpenergy";
  version = "1.3.8";

  src = fetchFromGitHub {
    owner = "lamoreauxlab";
    repo = "srpenergy-api-client-python";
    tag = version;
    hash = "sha256-V0WDY1tWt5O/35wDDE0e89bqspcKMtl9/QK2A7NIZu8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools==" "setuptools>="
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    python-dateutil
    requests
  ];

  disabledTestPaths = [
    # requires an account
    "quickstart_test.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "srpenergy.client" ];

  meta = {
    description = "Unofficial Python module for interacting with Srp Energy data";
    homepage = "https://github.com/lamoreauxlab/srpenergy-api-client-python";
    changelog = "https://github.com/lamoreauxlab/srpenergy-api-client-python/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
