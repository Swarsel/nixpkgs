{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  pyyaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyyaml-env-tag";
  version = "1.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    sha256 = "sha256-LrOLdaLSHuBHXW2X7BnGMoen4UAjHkIUlp0OrJI81/8=";
    pname = "pyyaml_env_tag";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ pyyaml ];
  pyproject = true;
  pythonImportsCheck = [ "yaml_env_tag" ];

  meta = {
    description = "Custom YAML tag for referencing environment variables";
    homepage = "https://github.com/waylan/pyyaml-env-tag";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
