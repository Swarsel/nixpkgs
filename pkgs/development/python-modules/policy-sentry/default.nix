{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  click,
  hatchling,
  orjson,
  pytestCheckHook,
  pyyaml,
  requests,
  schema,
}:

buildPythonPackage rec {
  pname = "policy-sentry";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "salesforce";
    repo = "policy_sentry";
    tag = version;
    hash = "sha256-oR8/hrntE4XzZHdbde+NoKWdsLs9jJ3RLIv8YsoDFt4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    beautifulsoup4
    click
    orjson
    pyyaml
    requests
    schema
  ];

  pyproject = true;
  pythonImportsCheck = [ "policy_sentry" ];
  pythonRelaxDeps = [ "beautifulsoup4" ];

  meta = {
    description = "Python module for generating IAM least privilege policies";
    homepage = "https://github.com/salesforce/policy_sentry";
    changelog = "https://github.com/salesforce/policy_sentry/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "policy_sentry";
  };
}
