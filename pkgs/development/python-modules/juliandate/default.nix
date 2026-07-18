{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "juliandate";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "seanredmond";
    repo = "juliandate";
    tag = "v${version}";
    hash = "sha256-pOWyrPBFqKmG9oKbXY/L14LblIcc8KfZSqZAEQP29V8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "juliandate" ];

  meta = {
    description = "Conversions between Julian Dates and Julian/Gregorian calendar dates";
    homepage = "https://github.com/seanredmond/juliandate";
    changelog = "https://github.com/seanredmond/juliandate/blob/${src.tag}/HISTORY.MD";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
