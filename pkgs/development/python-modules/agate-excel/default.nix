{
  lib,
  fetchFromGitHub,
  agate,
  buildPythonPackage,
  olefile,
  openpyxl,
  pytestCheckHook,
  setuptools,
  xlrd,
}:

buildPythonPackage (finalAttrs: {
  pname = "agate-excel";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "wireservice";
    repo = "agate-excel";
    tag = finalAttrs.version;
    hash = "sha256-sKy7NaRhJ4KYOOUKuNs0SGutUn8XEmSeQFQ/57gTGCg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    agate
    openpyxl
    xlrd
    olefile
  ];

  pyproject = true;
  pythonImportsCheck = [ "agate" ];

  meta = {
    description = "Adds read support for excel files to agate";
    homepage = "https://github.com/wireservice/agate-excel";
    changelog = "https://github.com/wireservice/agate-excel/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
