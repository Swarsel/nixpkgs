{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  keyring,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
}:

buildPythonPackage rec {
  pname = "upcloud-api";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "UpCloudLtd";
    repo = "upcloud-python-api";
    tag = "v${version}";
    hash = "sha256-OnHKKSlj6JbqXL1YDkmR7d6ae8eVdXOPx6Los5qPDJE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];
  dependencies = [ requests ];

  optional-dependencies = {
    keyring = [ keyring ];
  };

  pyproject = true;
  pythonImportsCheck = [ "upcloud_api" ];

  meta = {
    description = "UpCloud API Client";
    homepage = "https://github.com/UpCloudLtd/upcloud-python-api";
    changelog = "https://github.com/UpCloudLtd/upcloud-python-api/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
