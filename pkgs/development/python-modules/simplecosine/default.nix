{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  numpy,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "simplecosine";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "dedupeio";
    repo = "simplecosine";
    tag = "v${version}";
    hash = "sha256-TNQnSbCh7o5JsxvfljRGSNwptwpLHmVw9gyk0TELDek=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "simplecosine"
  ];

  meta = {
    description = "Simple cosine distance calculation for string comparison";
    homepage = "https://github.com/dedupeio/simplecosine";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ daniel-fahey ];
  };
}
