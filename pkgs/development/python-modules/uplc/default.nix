{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cbor2,
  cbor2WithoutCExtensions,
  frozendict,
  # Python deps
  frozenlist2,
  poetry-core,
  pycardano,
  python-secp256k1-cardano,
  rply,
  setuptools,
  uplc,
}:

buildPythonPackage rec {
  pname = "uplc";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "OpShin";
    repo = "uplc";
    tag = version;
    hash = "sha256-E9uCt1SW8nlhvsgALd24aD5QWjTyM2aO1d7+GZ+IHrA=";
  };

  # Support cbor2 without C extensions
  postPatch = lib.optionalString (!cbor2.withCExtensions) ''
    substituteInPlace uplc/ast.py --replace-fail 'from _cbor2' 'from cbor2'
  '';

  propagatedBuildInputs = [
    setuptools
    poetry-core
    frozendict
    cbor2
    frozenlist2
    rply
    pycardano
    python-secp256k1-cardano
  ];

  pyproject = true;
  pythonImportsCheck = [ "uplc" ];

  passthru.tests.withoutCExtensions = uplc.override {
    cbor2 = cbor2WithoutCExtensions;
  };

  meta = {
    description = "Python implementation of untyped plutus language core";
    homepage = "https://github.com/OpShin/uplc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aciceri ];
    mainProgram = "opshin";
  };
}
