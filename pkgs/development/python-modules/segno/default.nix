{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  flit-core,
  pypng,
  # tests
  pytestCheckHook,
  pyzbar,
}:

buildPythonPackage rec {
  pname = "segno";
  version = "1.6.6";

  src = fetchFromGitHub {
    owner = "heuer";
    repo = "segno";
    tag = version;
    hash = "sha256-A6lESmVogypit0SDeG4g9axn3+welSqTt1A17BNLmvU=";
  };

  nativeBuildInputs = [ flit-core ];

  nativeCheckInputs = [
    pytestCheckHook
    pypng
    pyzbar
  ];

  disabledTests = [
    # https://github.com/heuer/segno/issues/132
    "test_plugin"
  ];

  pyproject = true;
  pythonImportsCheck = [ "segno" ];

  meta = {
    description = "QR Code and Micro QR Code encoder";
    homepage = "https://github.com/heuer/segno/";
    changelog = "https://github.com/heuer/segno/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ phaer ];
    mainProgram = "segno";
  };
}
