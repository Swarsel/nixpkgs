{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  requests,
  requests-toolbelt,
}:

buildPythonPackage rec {
  pname = "aws-request-signer";
  version = "1.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-DVorDO0wz94Fhduax7VsQZ5B5SnBfsHQoLoW4m6Ce+U=";
    pname = "aws_request_signer";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "poetry>=0.12" poetry-core \
      --replace-fail poetry.masonry.api poetry.core.masonry.api
  '';

  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    requests
    requests-toolbelt
  ];

  pyproject = true;

  meta = {
    description = "Python library to sign AWS requests using AWS Signature V4";
    homepage = "https://github.com/iksteen/aws-request-signer";
    changelog = "https://github.com/iksteen/aws-request-signer/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
