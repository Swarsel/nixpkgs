{
  lib,
  fetchFromGitHub,
  base58,
  buildPythonPackage,
  dnspython,
  idna,
  netaddr,
  psutil,
  py-cid,
  py-multicodec,
  pytestCheckHook,
  setuptools,
  trio,
  trio-typing,
  varint,
}:

buildPythonPackage rec {
  pname = "py-multiaddr";
  version = "0.0.11";

  src = fetchFromGitHub {
    owner = "multiformats";
    repo = "py-multiaddr";
    tag = "v${version}";
    hash = "sha256-mlHcuLVtczp3APXJFkWbjeY7xU39eFERa8hhiOEwBSU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    varint
    base58
    netaddr
    dnspython
    trio-typing
    trio
    idna
    py-cid
    psutil
    py-multicodec
  ];

  disabledTestPaths = [
    # Tests require network access
    "tests/test_resolvers.py"
  ];

  disabledTests = [
    # Test is outdated
    "test_resolve_cancellation_with_error"
    # AssertionError
    "test_ipv4_wildcard"
  ];

  pyproject = true;
  pythonImportsCheck = [ "multiaddr" ];

  meta = {
    description = "Composable and future-proof network addresses";
    homepage = "https://github.com/multiformats/py-multiaddr";
    changelog = "https://github.com/multiformats/py-multiaddr/releases/tag/${src.tag}";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ Luflosi ];
  };
}
