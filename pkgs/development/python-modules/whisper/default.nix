{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "whisper";
  version = "1.1.10";

  src = fetchFromGitHub {
    owner = "graphite-project";
    repo = "whisper";
    tag = version;
    hash = "sha256-CnCbRmI2jc67mTtfupoE1uHtobrAiWoUXbfX8YeEV6A=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ six ];

  disabledTests = [
    # whisper-resize.py: not found
    "test_resize_with_aggregate"
  ];

  pyproject = true;
  pythonImportsCheck = [ "whisper" ];

  meta = {
    description = "Fixed size round-robin style database";
    homepage = "https://github.com/graphite-project/whisper";

    changelog = "https://graphite.readthedocs.io/en/latest/releases/${
      builtins.replaceStrings [ "." ] [ "_" ] version
    }.html";

    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      basvandijk
    ];
  };
}
