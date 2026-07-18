{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "cymem";
  version = "2.0.14";

  src = fetchFromGitHub {
    owner = "explosion";
    repo = "cymem";
    tag = "release-v${finalAttrs.version}";
    hash = "sha256-pb7AWkCOLfoH2kLNNwIxxHyGsxCpq72Qzid4aCYu9XM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # remove src module, so tests use the installed module instead
    mv ./cymem/tests ./tests
    rm -r ./cymem
  '';

  build-system = [
    setuptools
    cython
  ];

  pyproject = true;
  pythonImportsCheck = [ "cymem" ];

  meta = {
    description = "Cython memory pool for RAII-style memory management";
    homepage = "https://github.com/explosion/cymem";
    changelog = "https://github.com/explosion/cymem/releases/tag/release-${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickcao ];
  };
})
