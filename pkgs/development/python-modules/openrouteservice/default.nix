{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  responses,
}:

buildPythonPackage rec {
  pname = "openrouteservice";
  version = "2.3.3";

  src = fetchFromGitHub {
    owner = "GIScience";
    repo = "${pname}-py";
    rev = "v${version}";
    sha256 = "1d5qbygb81fhpwfdm1a118r3xv45xz9n9avfkgxkvw1n8y6ywz2q";
  };

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  disabledTests = [
    # touches network
    "test_optimized_waypoints"
    "test_invalid_api_key"
    "test_raise_timeout_retriable_requests"
  ];

  format = "setuptools";

  meta = {
    description = "Python API to consume openrouteservice(s) painlessly";
    homepage = "https://github.com/GIScience/openrouteservice-py";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ Scriptkiddi ];
  };
}
