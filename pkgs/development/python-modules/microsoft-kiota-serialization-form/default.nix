{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  gitUpdater,
  microsoft-kiota-abstractions,
  pendulum,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "microsoft-kiota-serialization-form";
  version = "1.11.7";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "kiota-python";
    tag = "microsoft-kiota-serialization-form-v${finalAttrs.version}";
    hash = "sha256-Fd9XSO3H1Au8y+Acft5to7hi7QNwWcmP0/NeWZlufjg=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ flit-core ];

  dependencies = [
    microsoft-kiota-abstractions
    pendulum
  ];

  pyproject = true;
  pythonImportsCheck = [ "kiota_serialization_form" ];
  sourceRoot = "${finalAttrs.src.name}/packages/serialization/form/";

  passthru.updateScript = gitUpdater {
    rev-prefix = "microsoft-kiota-serialization-form-v";
  };

  meta = {
    description = "Form serialization implementation for Kiota clients in Python";
    homepage = "https://github.com/microsoft/kiota-python/tree/main/packages/serialization/form";
    changelog = "https://github.com/microsoft/kiota-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
