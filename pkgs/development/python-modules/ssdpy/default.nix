{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ssdpy";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "MoshiBin";
    repo = "ssdpy";
    rev = version;
    hash = "sha256-luOanw4aOepGxoGtmnWZosq9JyHLJb3E+25tPkkL1w0=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
  ];

  disabledTests = [
    # They all require network access
    "test_client_json_output"
    "test_discover"
    "test_server_ipv4"
    "test_server_ipv6"
    "test_server_binds_iface"
    "test_server_bind_address_ipv6"
    "test_server_extra_fields"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ssdpy" ];

  meta = {
    description = "Lightweight, compatible SSDP library for Python";
    homepage = "https://github.com/MoshiBin/ssdpy";
    changelog = "https://github.com/MoshiBin/ssdpy/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mjm ];
    # Darwin's network interface names have changed since the package was last updated
    broken = stdenv.hostPlatform.isDarwin;
  };
}
