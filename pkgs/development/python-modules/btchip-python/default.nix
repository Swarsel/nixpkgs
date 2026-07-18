{
  lib,
  buildPythonPackage,
  ecdsa,
  fetchPypi,
  hidapi,
  pyscard,
}:

buildPythonPackage rec {
  pname = "btchip-python";
  version = "0.1.32";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-NPXgwWHAj2XcDQcLov9MMV7SHEt+D6oypGhi0Nwbj1U=";
  };

  postPatch = ''
    # fix extra_requires validation
    substituteInPlace setup.py \
      --replace "python-pyscard>=1.6.12-4build1" "python-pyscard>=1.6.12"
  '';

  propagatedBuildInputs = [
    hidapi
    ecdsa
  ];

  # tests requires hardware
  doCheck = false;
  format = "setuptools";
  optional-dependencies.smartcard = [ pyscard ];
  pythonImportsCheck = [ "btchip.btchip" ];

  meta = {
    description = "Python communication library for Ledger Hardware Wallet products";
    homepage = "https://github.com/LedgerHQ/btchip-python";
    license = lib.licenses.asl20;
  };
}
