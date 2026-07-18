{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  crc,
  pytest-asyncio_0,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyaprilaire";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "chamberlain2007";
    repo = "pyaprilaire";
    tag = version;
    hash = "sha256-5f/vo8aDQ0HVKXW/yiNYyH3zFnwvP5kv0ZEglvB5quo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio_0
  ];

  build-system = [ setuptools ];
  dependencies = [ crc ];
  pyproject = true;
  pythonImportsCheck = [ "pyaprilaire" ];

  meta = {
    description = "Python library for interacting with Aprilaire thermostats";
    homepage = "https://github.com/chamberlain2007/pyaprilaire";
    changelog = "https://github.com/chamberlain2007/pyaprilaire/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
