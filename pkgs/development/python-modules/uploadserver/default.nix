{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  curl,
  pytestCheckHook,
  requests,
  setuptools,
  urllib3,
}:
buildPythonPackage (finalAttrs: {
  pname = "uploadserver";
  version = "6.0.3";

  src = fetchFromGitHub {
    owner = "Densaugeo";
    repo = "uploadserver";
    tag = finalAttrs.version;
    hash = "sha256-aG/s7C55QaAvOMFWrYKlDdjQFWljKBjal2Qe6j1/B/o=";
  };

  env.PROTOCOL = "HTTP";
  env.VERBOSE = 0;

  nativeCheckInputs = [
    pytestCheckHook
    urllib3
    requests
    curl
  ];

  build-system = [ setuptools ];
  enabledTestPaths = [ "test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "uploadserver" ];

  meta = {
    description = "Python's http.server extended to include a file upload page";
    homepage = "https://github.com/Densaugeo/uploadserver";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.gigamonster256 ];
    mainProgram = "uploadserver";
  };
})
