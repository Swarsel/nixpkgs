{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "nlpcloud";
  version = "1.1.47";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zj6hurPEzNlbrD6trq+zQHBNg4lJMGw+XHV51rBa9Mk=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "nlpcloud" ];

  meta = {
    description = "Python client for the NLP Cloud API";
    homepage = "https://nlpcloud.com/";
    changelog = "https://github.com/nlpcloud/nlpcloud-python/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
