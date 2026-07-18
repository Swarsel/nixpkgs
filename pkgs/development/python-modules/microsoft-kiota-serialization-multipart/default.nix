{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  gitUpdater,
  microsoft-kiota-abstractions,
  microsoft-kiota-serialization-json,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "microsoft-kiota-serialization-multipart";
  version = "1.11.7";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "kiota-python";
    tag = "microsoft-kiota-serialization-multipart-v${version}";
    hash = "sha256-Fd9XSO3H1Au8y+Acft5to7hi7QNwWcmP0/NeWZlufjg=";
  };

  nativeCheckInputs = [
    microsoft-kiota-serialization-json
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ flit-core ];
  dependencies = [ microsoft-kiota-abstractions ];
  pyproject = true;
  pythonImportsCheck = [ "kiota_serialization_multipart" ];
  sourceRoot = "${src.name}/packages/serialization/multipart/";

  passthru.updateScript = gitUpdater {
    rev-prefix = "microsoft-kiota-serialization-multipart-v";
  };

  meta = {
    description = "Multipart serialization implementation for Kiota clients in Python";
    homepage = "https://github.com/microsoft/kiota-python/tree/main/packages/serialization/multipart";
    changelog = "https://github.com/microsoft/kiota-python/releases/tag/microsoft-kiota-serialization-multipart-${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
