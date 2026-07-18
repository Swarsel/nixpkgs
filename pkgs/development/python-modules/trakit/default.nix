{
  lib,
  fetchFromGitHub,
  # dependencies
  babelfish,
  buildPythonPackage,
  # build dependencies
  poetry-core,
  # tests
  pytestCheckHook,
  pyyaml,
  rebulk,
  unidecode,
}:

buildPythonPackage rec {
  pname = "trakit";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "ratoaq2";
    repo = "trakit";
    tag = version;
    hash = "sha256-x/83yRzvQ81+wS0lJr52KYBMoPvSVDr17ppxG/lSfUg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    unidecode
  ];

  build-system = [ poetry-core ];

  dependencies = [
    babelfish
    pyyaml
    rebulk
  ];

  disabledTests = [
    # requires network access
    "test_generate_config"
  ];

  pyproject = true;
  pythonImportsCheck = [ "trakit" ];

  meta = {
    description = "Guess additional information from track titles";
    homepage = "https://github.com/ratoaq2/trakit";
    changelog = "https://github.com/ratoaq2/trakit/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eljamm ];
  };
}
