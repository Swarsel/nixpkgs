{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  yarl,
}:

buildPythonPackage rec {
  pname = "qbusmqttapi";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "Qbus-iot";
    repo = "qbusmqttapi";
    tag = "v${version}";
    hash = "sha256-dxrJzmDb+uClZYfIjhUStYcNOSm90pIZlNdxbbRl4N0=";
  };

  postPatch = ''
    # Upstream uses a placeholder version in pyproject.toml
    substituteInPlace pyproject.toml \
      --replace-fail '"0.0.0"' '"${version}"'
  '';

  # upstream has no tests
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "qbusmqttapi" ];

  meta = {
    description = "MQTT API for Qbus Home Automation";
    homepage = "https://github.com/Qbus-iot/qbusmqttapi";
    changelog = "https://github.com/Qbus-iot/qbusmqttapi/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
