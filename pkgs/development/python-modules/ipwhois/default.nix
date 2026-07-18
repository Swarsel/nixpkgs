{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  dnspython,
  iana-etc,
  libredirect,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ipwhois";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "secynic";
    repo = "ipwhois";
    tag = "v${version}";
    hash = "sha256-PY3SUPELcCvS/o5kfko4OD1BlTc9DnyqfkSFuzcAOSY=";
  };

  nativeCheckInputs = [
    libredirect.hook
    pytestCheckHook
  ];

  preCheck = lib.optionalString stdenv.hostPlatform.isLinux ''
    echo "nameserver 127.0.0.1" > resolv.conf
    export NIX_REDIRECTS=/etc/protocols=${iana-etc}/etc/protocols:/etc/resolv.conf=$(realpath resolv.conf)
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    defusedxml
    dnspython
  ];

  disabledTestPaths = [
    # Tests require network access
    "ipwhois/tests/online/"
    # Stress test
    "ipwhois/tests/stress/test_experimental.py"
  ];

  disabledTests = [
    "test_lookup"
    "test_unique_addresses"
    "test_get_http_json"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ipwhois" ];
  pythonRelaxDeps = [ "dnspython" ];

  meta = {
    description = "Library to retrieve and parse whois data";
    homepage = "https://github.com/secynic/ipwhois";
    changelog = "https://github.com/secynic/ipwhois/blob/v${version}/CHANGES.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
}
