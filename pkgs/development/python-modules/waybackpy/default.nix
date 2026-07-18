{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  pytest,
  requests,
  setuptools,
  urllib3,
}:
buildPythonPackage (finalAttrs: {
  pname = "waybackpy";
  version = "3.0.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-SXo3F1arp2ROt62g69TtsVy4xTvBNMyXO/AjoSyv+D8=";
  };

  nativeBuildInputs = [ pytest ];
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    click
    urllib3
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "waybackpy" ];

  meta = {
    description = "Wayback Machine API interface & a command-line tool";
    homepage = "https://akamhy.github.io/waybackpy/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ chpatrick ];
  };
})
