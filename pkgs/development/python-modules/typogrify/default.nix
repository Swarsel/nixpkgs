{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  pytestCheckHook,
  smartypants,
}:

buildPythonPackage rec {
  pname = "typogrify";
  version = "2.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8KoATpgDKm5r5MnaZefrcVDjbKO/UIrbzagrTQA+Ye4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ smartypants ];

  enabledTestPaths = [
    "typogrify/filters.py"
    "typogrify/packages/titlecase/tests.py"
  ];

  pyproject = true;

  pytestFlags = [
    "--doctest-modules"
  ];

  pythonImportsCheck = [ "typogrify.filters" ];

  meta = {
    description = "Filters to enhance web typography, including support for Django & Jinja templates";
    homepage = "https://github.com/justinmayer/typogrify";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
