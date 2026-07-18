{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pycryptodomex,
  pytestCheckHook,
  requests,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "pyjwkest";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "IdentityPython";
    repo = "pyjwkest";
    tag = "v${version}";
    hash = "sha256-G4/qLOOQHsNSMVndUdYBhrrk8uEufbI8Od3ziQiY0XI=";
  };

  # Remove unused future import, see pending PR:
  # https://github.com/IdentityPython/pyjwkest/pull/107
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail '"future"' ""
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    pycryptodomex
    requests
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "jwkest" ];

  meta = {
    description = "Implementation of JWT, JWS, JWE and JWK";
    homepage = "https://github.com/IdentityPython/pyjwkest";
    license = lib.licenses.asl20;
  };
}
