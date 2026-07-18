{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pynmeagps";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pynmeagps";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uVIlr+zRwbaQqtInJqCebzMR5pe7dEls3gVzbW7TYkQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pynmeagps" ];

  meta = {
    description = "NMEA protocol parser and generator";
    homepage = "https://github.com/semuconsulting/pynmeagps";
    changelog = "https://github.com/semuconsulting/pynmeagps/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dylan-gonzalez ];
  };
})
