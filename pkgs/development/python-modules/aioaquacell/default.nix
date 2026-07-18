{
  lib,
  fetchFromGitHub,
  aiohttp,
  aws-request-signer,
  boto3,
  botocore,
  buildPythonPackage,
  poetry-core,
  pycognito,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioaquacell";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Jordi1990";
    repo = "aioaquacell";
    tag = finalAttrs.version;
    hash = "sha256-ghzuNIqpDwrt2EJ8u74yF5pWdS2nR3FvbPdHQMH4KxE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"'
  '';

  doCheck = false; # no tests
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    aws-request-signer
    boto3
    botocore
    pycognito
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioaquacell" ];

  meta = {
    description = "Asynchronous library to retrieve details of your Aquacell water softener device";
    homepage = "https://github.com/Jordi1990/aioaquacell";
    changelog = "https://github.com/Jordi1990/aioaquacell/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
