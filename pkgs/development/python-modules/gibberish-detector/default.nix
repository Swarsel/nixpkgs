{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "gibberish-detector";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "domanchi";
    repo = "gibberish-detector";
    rev = "v${version}";
    sha256 = "1si0fkpnk9vjkwl31sq5jkyv3rz8a5f2nh3xq7591j9wv2b6dn0b";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "gibberish_detector" ];

  meta = {
    description = "Python module to detect gibberish strings";
    homepage = "https://github.com/domanchi/gibberish-detector";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "gibberish-detector";
  };
}
