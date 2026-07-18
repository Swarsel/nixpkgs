{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ajsonrpc";
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eRusGPC/De4QkZRkTxUc+Lf/UpxLjWI5rEgQSjJRoZ8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ajsonrpc" ];

  meta = {
    description = "Async JSON-RPC 2.0 protocol and asyncio server";
    homepage = "https://github.com/pavlov99/ajsonrpc";
    changelog = "https://github.com/pavlov99/ajsonrpc/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "async-json-rpc-server";
  };
}
