{
  lib,
  boto3,
  buildPythonPackage,
  envs,
  fetchPypi,
  python-jose,
  requests,
}:

buildPythonPackage rec {
  pname = "warrant-lite";
  version = "1.0.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-FunWoslZn3o0WHet2+LtggO3bbbe2ULMXW93q07GxJ4=";
  };

  postPatch = ''
    # requirements.txt is not part of the source
    substituteInPlace setup.py \
      --replace "parse_requirements('requirements.txt')," "[],"
  '';

  propagatedBuildInputs = [
    boto3
    envs
    python-jose
    requests
  ];

  # Tests require credentials
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "warrant_lite" ];

  meta = {
    description = "Module for process SRP requests for AWS Cognito";
    homepage = "https://github.com/capless/warrant-lite";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
