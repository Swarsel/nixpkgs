{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "xmltodict";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "martinblech";
    repo = "xmltodict";
    tag = "v${version}";
    hash = "sha256-G7hVtS6toUJC0YY1AXBOJSc3wnAZyWilLnT/5vvFRRw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "xmltodict" ];

  meta = {
    description = "Makes working with XML feel like you are working with JSON";
    homepage = "https://github.com/martinblech/xmltodict";
    changelog = "https://github.com/martinblech/xmltodict/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
