{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pathable,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
  pyyaml,
  referencing,
  responses,
}:

buildPythonPackage rec {
  pname = "jsonschema-path";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "p1c2u";
    repo = "jsonschema-path";
    tag = version;
    hash = "sha256-CDDwhIlwytUPVwq/+0T5kVzl8viJfSalSIxC5VrQdgs=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    responses
  ];

  build-system = [ poetry-core ];

  dependencies = [
    pathable
    pyyaml
    referencing
  ];

  pyproject = true;
  pythonImportsCheck = [ "jsonschema_path" ];

  meta = {
    description = "JSONSchema Spec with object-oriented paths";
    homepage = "https://github.com/p1c2u/jsonschema-path";
    changelog = "https://github.com/p1c2u/jsonschema-path/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
