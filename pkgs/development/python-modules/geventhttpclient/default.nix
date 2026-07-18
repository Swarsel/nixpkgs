{
  lib,
  stdenv,
  fetchFromGitHub,
  brotli,
  buildPythonPackage,
  certifi,
  dpkt,
  gevent,
  pytestCheckHook,
  setuptools,
  urllib3,
}:

buildPythonPackage rec {
  pname = "geventhttpclient";
  version = "2.3.7";

  src = fetchFromGitHub {
    owner = "geventhttpclient";
    repo = "geventhttpclient";
    tag = version;
    hash = "sha256-vca2uCQ1S21xQmAXdpLhI0DFZYUSyKhSkvETa2VqbkA=";
    # TODO: unvendor llhttp
    fetchSubmodules = true;
  };

  # lots of: [Errno 48] Address already in use: ('127.0.0.1', 54323)
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    dpkt
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    brotli
    certifi
    gevent
    urllib3
  ];

  disabledTestMarks = [ "network" ];
  pyproject = true;
  pythonImportsCheck = [ "geventhttpclient" ];

  meta = {
    description = "High performance, concurrent HTTP client library using gevent";
    homepage = "https://github.com/geventhttpclient/geventhttpclient";
    changelog = "https://github.com/geventhttpclient/geventhttpclient/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ koral ];
  };
}
