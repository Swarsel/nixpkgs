{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  python-dateutil,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "socid-extractor";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "soxoj";
    repo = "socid-extractor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZYLoHFyRnSHP3Od/cMOx690KFbJoEYK3cICjzbSfLm0=";
  };

  # Test require network access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    python-dateutil
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "socid_extractor" ];
  pythonRelaxDeps = [ "beautifulsoup4" ];

  meta = {
    description = "Python module to extract details from personal pages";
    homepage = "https://github.com/soxoj/socid-extractor";
    changelog = "https://github.com/soxoj/socid-extractor/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "socid_extractor";
  };
})
