{
  lib,
  buildPythonPackage,
  ecdsa,
  ed25519,
  fetchPypi,
  keepkey,
  libagent,
  mnemonic,
  pinentry,
  semver,
  setuptools,
  trezor,
  wheel,
}:

buildPythonPackage rec {
  pname = "trezor-agent";
  version = "0.12.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-4IylpUvXZYAXFkyFGNbN9iPTsHff3M/RL2Eq9f7wWFU=";
    pname = "trezor_agent";
  };

  # relax dependency constraint
  postPatch = ''
    substituteInPlace setup.py \
      --replace "trezor[hidapi]>=0.12.0,<0.13" "trezor[hidapi]>=0.12.0,<0.14"
  '';

  propagatedBuildInputs = [
    setuptools
    trezor
    libagent
    ecdsa
    ed25519
    mnemonic
    keepkey
    semver
    wheel
    pinentry
  ];

  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "libagent" ];

  meta = {
    description = "Using Trezor as hardware SSH agent";
    homepage = "https://github.com/romanz/trezor-agent";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      hkjn
      np
      mmahut
    ];
  };
}
