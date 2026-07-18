{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docopt,
  fastavro,
  pytestCheckHook,
  requests,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "hdfs";
  version = "2.7.3";

  src = fetchFromGitHub {
    owner = "mtth";
    repo = "hdfs";
    tag = "v${version}";
    hash = "sha256-Pm2E8hB0wbu7npi/sLt9D8jQsH69qNOHLji9CYqST/8=";
  };

  nativeCheckInputs = [
    fastavro
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    docopt
    requests
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "hdfs" ];

  meta = {
    description = "Python API and command line interface for HDFS";
    homepage = "https://github.com/mtth/hdfs";
    changelog = "https://github.com/mtth/hdfs/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ samuela ];
    mainProgram = "hdfscli";
  };
}
