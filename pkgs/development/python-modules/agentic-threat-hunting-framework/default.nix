{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  jinja2,
  pytest-cov-stub,
  pytestCheckHook,
  python-dotenv,
  pyyaml,
  requests,
  rich,
  scikit-learn,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "agentic-threat-hunting-framework";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "Nebulock-Inc";
    repo = "agentic-threat-hunting-framework";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5E9nUSGwEuGdt04M0rRoHES8Klco6j5X1TLa/E7KdgM=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    requests
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    jinja2
    python-dotenv
    pyyaml
    rich
  ];

  optional-dependencies = {
    similarity = [ scikit-learn ];
  };

  pyproject = true;
  pythonImportsCheck = [ "athf" ];

  meta = {
    description = "Framework for agentic threat hunting";
    homepage = "https://github.com/Nebulock-Inc/agentic-threat-hunting-framework";
    changelog = "https://github.com/Nebulock-Inc/agentic-threat-hunting-framework/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
