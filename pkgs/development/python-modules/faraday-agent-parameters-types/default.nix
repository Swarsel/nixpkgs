{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  marshmallow,
  packaging,
  pytestCheckHook,
  setuptools,
  validators,
}:

buildPythonPackage (finalAttrs: {
  pname = "faraday-agent-parameters-types";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "infobyte";
    repo = "faraday_agent_parameters_types";
    tag = finalAttrs.version;
    hash = "sha256-Oe/9/zKOoCLK3JHMacOhk2+d91MrhzkBTW3POoFm71M=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-warn '"pytest-runner",' ""
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    marshmallow
    packaging
    validators
  ];

  disabledTests = [
    # assert 'Version requested not valid' in "Invalid version: 'hola'"
    "test_incorrect_version_requested"
    # Tests are outdated
    "test_deserialize"
    "test_invalid_data"
    "test_serialize"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "faraday_agent_parameters_types"
    "faraday_agent_parameters_types.utils"
  ];

  pythonRelaxDeps = [
    "marshmallow"
    "validators"
  ];

  meta = {
    description = "Collection of Faraday agent parameters types";
    homepage = "https://github.com/infobyte/faraday_agent_parameters_types";
    changelog = "https://github.com/infobyte/faraday_agent_parameters_types/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
})
