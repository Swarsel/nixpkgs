{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isPy3k,
  pytestCheckHook,
  pyyaml,
  requests,
  requests-mock,
  setuptools,
  sqlite-utils,
}:

buildPythonPackage (finalAttrs: {
  pname = "github-to-sqlite";
  version = "2.9";

  src = fetchFromGitHub {
    owner = "dogsheep";
    repo = "github-to-sqlite";
    tag = finalAttrs.version;
    hash = "sha256-KwLaaZxBBzRhiBv4p8Imb5XI1hyka9rmr/rxA6wDc7Q=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    sqlite-utils
    pyyaml
    requests
  ];

  disabled = !isPy3k;
  disabledTests = [ "test_scrape_dependents" ];
  pyproject = true;

  meta = {
    description = "Save data from GitHub to a SQLite database";
    homepage = "https://github.com/dogsheep/github-to-sqlite";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sarcasticadmin ];
    mainProgram = "github-to-sqlite";
  };
})
