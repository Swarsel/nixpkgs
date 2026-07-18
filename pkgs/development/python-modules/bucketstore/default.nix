{
  lib,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  moto,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "bucketstore";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "jpetrucciani";
    repo = "bucketstore";
    tag = version;
    hash = "sha256-WjweYFnlDEoR+TYzNgjPMdCLdUUEbdPROubov6kancc=";
  };

  propagatedBuildInputs = [ boto3 ];

  nativeCheckInputs = [
    moto
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "bucketstore" ];

  meta = {
    description = "Library for interacting with Amazon S3";
    homepage = "https://github.com/jpetrucciani/bucketstore";
    changelog = "https://github.com/jpetrucciani/bucketstore/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jpetrucciani ];
  };
}
