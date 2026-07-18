{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  python-socks,
  setuptools,
}:

buildPythonPackage rec {
  pname = "websocket-client";
  version = "1.9.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-noE2JLbrYZmZqX3HlYRpIXwxdjErOhakvRvH4IpG7Jg=";
    pname = "websocket_client";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  optional-dependencies = {
    optional = [
      python-socks
      # wsaccel is not available at the moment
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "websocket" ];

  meta = {
    description = "Websocket client for Python";
    homepage = "https://github.com/websocket-client/websocket-client";
    changelog = "https://github.com/websocket-client/websocket-client/blob/v${version}/ChangeLog";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "wsdump";
  };
}
