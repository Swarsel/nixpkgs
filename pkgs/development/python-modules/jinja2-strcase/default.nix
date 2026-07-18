{
  lib,
  buildPythonPackage,
  fetchPypi,
  freezegun,
  jinja2,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jinja2-strcase";
  version = "0.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-2Qw3971A00WqzI94sIf2bmxapMloqyOnkVc/z3VsM3k=";
  };

  doCheck = false; # no tests

  nativeCheckInputs = [
    freezegun
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ jinja2 ];
  pyproject = true;
  pythonImportsCheck = [ "jinja2_strcase" ];

  meta = {
    description = "Library for converting string case in Jinja2 templates";
    homepage = "https://github.com/marchmiel/jinja2-strcase";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ crimeminister ];
  };
}
