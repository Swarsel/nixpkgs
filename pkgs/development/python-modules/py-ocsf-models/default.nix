{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  email-validator,
  poetry-core,
  pydantic,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-ocsf-models";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "prowler-cloud";
    repo = "py-ocsf-models";
    tag = finalAttrs.version;
    hash = "sha256-MdDpCr6FuPEt67PUjF0MjWXiA+ZyKLiACc/XPp+NoII=";
  };

  # Tests are outdated
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    cryptography
    email-validator
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "py_ocsf_models" ];
  pythonRelaxDeps = true;

  meta = {
    description = "OCSF models in Python using Pydantic";
    homepage = "https://github.com/prowler-cloud/py-ocsf-models";
    changelog = "https://github.com/prowler-cloud/py-ocsf-models/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
