{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  pandas,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "tinyhtml";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "niklasf";
    repo = "python-tinyhtml";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1DPQFszrNsGNEpEl4c1SNdnNfwi3bcHzCrOWdu+dTGA=";
  };

  nativeCheckInputs = [
    pandas
    jinja2
  ];

  # https://github.com/niklasf/python-tinyhtml/blob/master/tox.ini
  checkPhase = ''
    runHook preCheck
    python -m doctest README.rst
    runHook postCheck
  '';

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "tinyhtml"
  ];

  meta = {
    description = "Tiny library to safely render compact HTML5 from Python expressions";
    homepage = "https://github.com/niklasf/python-tinyhtml";
    changelog = "https://github.com/niklasf/python-tinyhtml/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
