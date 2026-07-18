{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "csvkit";
  version = "2.2.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-FHMYqNuuwHwLu5KRwUt43l+jLtPUpcI5blKoPAow32s=";
  };

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    agate
    agate-excel
    agate-dbf
    agate-sql
    setuptools # csvsql imports pkg_resources
  ];

  disabledTests = [
    # Tries to compare CLI output - and fails!
    "test_decimal_format"
  ];

  pyproject = true;
  pythonImportsCheck = [ "csvkit" ];

  meta = {
    description = "Suite of command-line tools for converting to and working with CSV";
    homepage = "https://github.com/wireservice/csvkit";
    changelog = "https://github.com/wireservice/csvkit/blob/${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
