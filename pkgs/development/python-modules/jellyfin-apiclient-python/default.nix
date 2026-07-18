{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  certifi,
  pytestCheckHook,
  requests,
  setuptools,
  urllib3,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "jellyfin-apiclient-python";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-apiclient-python";
    tag = "v${version}";
    hash = "sha256-lxwJgYysp/6C/eYviYJu5lfStWulHyl7WxqxMnOE5iw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    certifi
    requests
    urllib3
    websocket-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "jellyfin_apiclient_python" ];

  meta = {
    description = "Python API client for Jellyfin";
    homepage = "https://github.com/jellyfin/jellyfin-apiclient-python";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ jojosch ];
  };
}
