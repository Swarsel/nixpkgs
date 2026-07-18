{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  spacy,
}:

buildPythonPackage rec {
  pname = "spacy-lookups-data";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "explosion";
    repo = "spacy-lookups-data";
    tag = "v${version}";
    hash = "sha256-6sKZ+GgCjLWYnV96nub4xEUFh1qpPQpbnoxyOVrvcD0=";
  };

  nativeCheckInputs = [
    spacy
    pytestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "spacy_lookups_data" ];

  meta = {
    description = "Additional lookup tables and data resources for spaCy";
    homepage = "https://pypi.org/project/spacy-lookups-data";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jboy ];
  };
}
