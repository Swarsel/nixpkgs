{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  gitUpdater,
  microsoft-kiota-abstractions,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
}:

buildPythonPackage rec {
  pname = "microsoft-kiota-serialization-text";
  version = "1.11.7";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "kiota-python";
    tag = "microsoft-kiota-serialization-text-v${version}";
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
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "kiota_serialization_text" ];
  sourceRoot = "${src.name}/packages/serialization/text/";

  passthru.updateScript = gitUpdater {
    rev-prefix = "microsoft-kiota-serialization-text-v";
  };

  meta = {
    description = "Text serialization implementation for Kiota generated clients in Python";
    homepage = "https://github.com/microsoft/kiota-python/tree/main/packages/serialization/text";
    changelog = "https://github.com/microsoft/kiota-python/releases/tag/microsoft-kiota-serialization-text-${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
