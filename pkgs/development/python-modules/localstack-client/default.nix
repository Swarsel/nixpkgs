{
  lib,
  boto3,
  buildPythonPackage,
  fetchPypi,
  # use for testing promoted localstack
  pkgs,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "localstack-client";
  version = "2.11";

  src = fetchPypi {
    inherit version;
    hash = "sha256-HL178fA7m1U//n6hD+E39E6NaQo3r5xlFeumGiN5/EY=";
    pname = "localstack_client";
  };

  propagatedBuildInputs = [ boto3 ];
  # All commands test `localstack` which is a downstream dependency
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  # For tests
  __darwinAllowLocalNetworking = true;

  disabledTests = [
    # Has trouble creating a socket
    "test_session"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "localstack_client" ];

  passthru.tests = {
    inherit (pkgs) localstack;
  };

  meta = {
    description = "Lightweight Python client for LocalStack";
    homepage = "https://github.com/localstack/localstack-python-client";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
