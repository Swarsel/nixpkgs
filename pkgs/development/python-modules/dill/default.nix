{
  lib,
  fetchFromGitHub,
  # passthru tests
  apache-beam,
  buildPythonPackage,
  datasets,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "dill";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "uqfoundation";
    repo = "dill";
    tag = finalAttrs.version;
    hash = "sha256-Yh9WvescLgV7DmxGBTGKsb29+eRzF9qjZMg0DQQyLyY=";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} dill/tests/__main__.py
    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "dill" ];

  passthru.tests = {
    inherit apache-beam datasets;
  };

  meta = {
    description = "Serialize all of python (almost)";
    homepage = "https://github.com/uqfoundation/dill/";
    changelog = "https://github.com/uqfoundation/dill/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
  };
})
