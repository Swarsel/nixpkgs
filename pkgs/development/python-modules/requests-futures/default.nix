{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  greenlet,
  pytest-cov-stub,
  pytest-httpbin,
  pytestCheckHook,
  requests,
  setuptools,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "requests-futures";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "ross";
    repo = "requests-futures";
    tag = "v${version}";
    hash = "sha256-eUu+M9rPyvc7OaOCCnUvGliK4gicYh6hfB0Jo19Yy1g=";
  };

  nativeCheckInputs = [
    greenlet
    pytestCheckHook
    pytest-cov-stub
    pytest-httpbin
    werkzeug
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "requests_futures" ];

  meta = {
    description = "Asynchronous Python HTTP Requests for Humans using Futures";
    homepage = "https://github.com/ross/requests-futures";
    changelog = "https://github.com/ross/requests-futures/blob/${src.tag}/CHANGELOG.md";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ applePrincess ];
  };
}
