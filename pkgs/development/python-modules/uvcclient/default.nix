{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  poetry-core,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "uvcclient";
  version = "0.12.2";

  src = fetchFromGitHub {
    owner = "kk7ds";
    repo = "uvcclient";
    tag = "v${version}";
    hash = "sha256-V7xIvZ9vIXHPpkEeJZ6QedWk+4ZVNwCzj5ffLyixFz4=";
  };

  nativeCheckInputs = [
    mock
    pytest-cov-stub
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  pyproject = true;

  meta = {
    description = "Client for Ubiquiti's Unifi Camera NVR";
    homepage = "https://github.com/kk7ds/uvcclient";
    changelog = "https://github.com/uilibs/uvcclient/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "uvc";
  };
}
