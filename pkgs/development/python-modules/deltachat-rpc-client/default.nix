{
  lib,
  buildPythonPackage,
  deltachat-rpc-server,
  imap-tools,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  inherit (deltachat-rpc-server) version src;
  pname = "deltachat-rpc-client";

  postPatch = ''
    substituteInPlace src/deltachat_rpc_client/rpc.py \
      --replace-fail deltachat-rpc-server "${lib.getExe deltachat-rpc-server}"
  '';

  # requires a chatmail server
  doCheck = false;

  nativeCheckInputs = [
    imap-tools
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "deltachat_rpc_client" ];
  sourceRoot = "${src.name}/deltachat-rpc-client";

  meta = {
    inherit (deltachat-rpc-server.meta) changelog license maintainers;
    description = "Python client for Delta Chat core JSON-RPC interface";
    homepage = "https://github.com/deltachat/deltachat-core-rust/tree/main/deltachat-rpc-client";
  };
}
