{
  lib,
  buildPythonPackage,
  fetchPypi,
  gnupg,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pycoin";
  version = "0.92.20241201";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-bpN74YFXPM8Cs1BkhEvsRt4TA4a0Xz3xltMHSox5BRI=";
  };

  postPatch = ''
    substituteInPlace ./pycoin/cmds/tx.py --replace '"gpg"' '"${gnupg}/bin/gpg"'
  '';

  propagatedBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];

  # Disable tests depending on online services
  disabledTests = [
    "ServicesTest"
    "test_tx_pay_to_opcode_list_txt"
    "test_tx_fetch_unspent"
    "test_tx_with_gpg"
  ];

  format = "setuptools";

  meta = {
    description = "Utilities for Bitcoin and altcoin addresses and transaction manipulation";
    homepage = "https://github.com/richardkiss/pycoin";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nyanloutre ];
  };
}
