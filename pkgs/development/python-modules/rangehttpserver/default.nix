{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest7CheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rangehttpserver";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "danvk";
    repo = "RangeHTTPServer";
    tag = version;
    hash = "sha256-wvGJ5wHYLb7wJUGgurkdRTABV6kTH7/GXzXgpd0Ypbc=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytest7CheckHook
    requests
  ];

  __darwinAllowLocalNetworking = true;
  pyproject = true;
  pythonImportsCheck = [ "RangeHTTPServer" ];

  meta = {
    description = "SimpleHTTPServer with support for Range requests";
    homepage = "https://github.com/danvk/RangeHTTPServer";
    changelog = "https://github.com/danvk/RangeHTTPServer/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
