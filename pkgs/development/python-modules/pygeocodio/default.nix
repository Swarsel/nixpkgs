{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  httpretty,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "pygeocodio";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "bennylope";
    repo = "pygeocodio";
    tag = "v${version}";
    hash = "sha256-4jT/PX+jvJx81eaSXTsb/vLNbv4dNNVgeYrE7QwGlL8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    requests
    httpretty
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    "test_timeout"
  ];

  pyproject = true;
  pythonImportsCheck = [ "geocodio" ];

  meta = {
    description = "Python wrapper for the Geocodio geolocation service API";
    homepage = "https://www.geocod.io/docs/#introduction";
    changelog = "https://github.com/bennylope/pygeocodio/blob/${src.tag}/HISTORY.rst";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    downloadPage = "https://github.com/bennylope/pygeocodio/tree/master";
  };
}
