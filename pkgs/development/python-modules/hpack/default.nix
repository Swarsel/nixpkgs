{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "hpack";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "python-hyper";
    repo = "hpack";
    rev = "v${version}";
    hash = "sha256-vbxfDlRDwMXuzkPO0oceCpSz1ekLNxLSj4iocdHo680=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "hpack" ];

  meta = {
    description = "Pure-Python HPACK header compression";
    homepage = "https://github.com/python-hyper/hpack";
    changelog = "https://github.com/python-hyper/hpack/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
