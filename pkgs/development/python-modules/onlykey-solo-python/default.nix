{
  lib,
  buildPythonPackage,
  click,
  ecdsa,
  fetchPypi,
  fetchpatch,
  fido2,
  intelhex,
  pyserial,
  pyusb,
  requests,
}:

buildPythonPackage rec {
  pname = "onlykey-solo-python";
  version = "0.0.32";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-88DuhgX4FCwzIKzw4RqWgMtjRdf5huVlKEHAAEminuQ=";
  };

  patches = [
    # https://github.com/trustcrypto/onlykey-solo-python/pull/3
    (fetchpatch {
      hash = "sha256-O0XQoWwhwvLc0CchUTXSuWgHMNG2ZPDy7FsU3RQrdp8=";
      url = "https://github.com/trustcrypto/onlykey-solo-python/commit/dfebd6b36087f5f918da8c1af5a3236581cccf2d.patch";
    })
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace "fido2 == 0.9.3" "fido2"
  '';

  propagatedBuildInputs = [
    click
    ecdsa
    fido2
    intelhex
    pyserial
    pyusb
    requests
  ];

  # no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "solo" ];

  meta = {
    description = "Python library for OnlyKey with Solo FIDO2";
    homepage = "https://github.com/trustcrypto/onlykey-solo-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kalbasit ];
    mainProgram = "solo";
  };
}
