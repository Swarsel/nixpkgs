{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  normality,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "fingerprints";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "alephdata";
    repo = "fingerprints";
    tag = version;
    hash = "sha256-Q+XCsuGMHPtOqB0SauVuYInR5FGMuG6aNhqiAwTJvSI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  dependencies = [ normality ];
  pyproject = true;
  pythonImportsCheck = [ "fingerprints" ];

  meta = {
    description = "Library to generate entity fingerprints";
    homepage = "https://github.com/alephdata/fingerprints";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
