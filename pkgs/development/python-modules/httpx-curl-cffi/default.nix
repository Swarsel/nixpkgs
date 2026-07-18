{
  lib,
  buildPythonPackage,
  curl-cffi,
  fetchPypi,
  httpx,
  pdm-backend,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "httpx-curl-cffi";
  version = "0.1.5";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-F37plo6doUJAcBeBbMP7CKsoGxNPdzqTWbakZQpsgfM=";
    pname = "httpx_curl_cffi";
  };

  build-system = [
    pdm-backend
  ];

  dependencies = [
    curl-cffi
    httpx
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "httpx_curl_cffi"
  ];

  meta = {
    description = "Httpx transport for curl_cffi (python bindings for curl-impersonate";
    homepage = "https://pypi.org/project/httpx-curl-cffi";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ xanderio ];
  };
})
