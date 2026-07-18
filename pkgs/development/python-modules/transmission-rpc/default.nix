{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  python-dotenv,
  pytz,
  requests,
  setuptools,
  typing-extensions,
  yarl,
}:

buildPythonPackage rec {
  pname = "transmission-rpc";
  version = "7.0.11";

  src = fetchFromGitHub {
    owner = "Trim21";
    repo = "transmission-rpc";
    tag = "v${version}";
    hash = "sha256-t07TuLLHfbxvWh+7854OMigfGC8jHzvpd4QO3v0M15I=";
  };

  nativeCheckInputs = [
    python-dotenv
    pytz
    pytestCheckHook
    yarl
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    typing-extensions
  ];

  disabledTests = [
    # Tests require a running Transmission instance
    "test_groups"
    "test_real"
  ];

  pyproject = true;
  pythonImportsCheck = [ "transmission_rpc" ];

  meta = {
    description = "Python module that implements the Transmission bittorent client RPC protocol";
    homepage = "https://github.com/Trim21/transmission-rpc";
    changelog = "https://github.com/trim21/transmission-rpc/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eyjhb ];
  };
}
