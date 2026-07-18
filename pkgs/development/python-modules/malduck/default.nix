{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  capstone,
  click,
  cryptography,
  dnfile,
  pefile,
  pycryptodomex,
  pyelftools,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  typing-extensions,
  yara-python,
}:

buildPythonPackage rec {
  pname = "malduck";
  version = "4.4.1";

  src = fetchFromGitHub {
    owner = "CERT-Polska";
    repo = "malduck";
    tag = "v${version}";
    hash = "sha256-Btx0HxiZWrb0TDpBokQGtBE2EDK0htONe/DwqlPgAd4=";
  };

  patches = lib.optionals (pythonAtLeast "3.14") [
    # python 3.14 ctypes rejects `_pack_` without `_layout_ = "ms"`.
    ./python-3.14-ctypes-layout.patch
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    capstone
    click
    cryptography
    dnfile
    pefile
    pycryptodomex
    pyelftools
    typing-extensions
    yara-python
  ];

  pyproject = true;
  pythonImportsCheck = [ "malduck" ];

  meta = {
    description = "Helper for malware analysis";
    homepage = "https://github.com/CERT-Polska/malduck";
    changelog = "https://github.com/CERT-Polska/malduck/releases/tag/v${version}";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "malduck";
  };
}
