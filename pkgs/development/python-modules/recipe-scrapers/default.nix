{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  extruct,
  isodate,
  language-tags,
  nixosTests,
  pytestCheckHook,
  regex,
  requests,
  responses,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "recipe-scrapers";
  version = "15.11.0";

  src = fetchFromGitHub {
    owner = "hhursev";
    repo = "recipe-scrapers";
    tag = finalAttrs.version;
    hash = "sha256-S0/RPVeEr/lAPJZSUwCippuXyirYnmaAuesWGYwg6kE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    extruct
    isodate
    language-tags
    regex
  ];

  disabledTests = [
    # Fixture is broken
    "test_instructions"
  ];

  optional-dependencies = {
    online = [ requests ];
  };

  pyproject = true;
  pythonImportsCheck = [ "recipe_scrapers" ];

  passthru = {
    tests = {
      inherit (nixosTests) mealie tandoor-recipes;
    };
  };

  meta = {
    description = "Python package for scraping recipes data";
    homepage = "https://github.com/hhursev/recipe-scrapers";
    changelog = "https://github.com/hhursev/recipe-scrapers/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
})
