{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiohttp-apispec,
  apispec,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  libnacl,
  marshmallow,
  packaging,
  pyasn1,
  pyopenssl,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pyipv8";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "tribler";
    repo = "py-ipv8";
    tag = version;
    hash = "sha256-lvkMWMwpKEbHcHZQ3rbG9MOS1/tufa/KphQT9iz5PcQ=";
  };

  doCheck = true;
  nativeCheckInputs = [ pytestCheckHook ];
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    libnacl
    aiohttp
    aiohttp-apispec
    pyopenssl
    pyasn1
    marshmallow
    typing-extensions
    packaging
    apispec
  ];

  pyproject = true;

  meta = {
    description = "Python implementation of Tribler's IPv8 p2p-networking layer";
    homepage = "https://github.com/Tribler/py-ipv8";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ mkg20001 ];
  };
}
