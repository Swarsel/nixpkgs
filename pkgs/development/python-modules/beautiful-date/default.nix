{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  freezegun,
  pytestCheckHook,
  python-dateutil,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "beautiful-date";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "kuzmoyev";
    repo = "beautiful-date";
    tag = "v${finalAttrs.version}";
    hash = "sha256-e6YJBaDwWqVehxBPOvsIdV4FIXlIwj29H5untXGJvT0=";
  };

  nativeCheckInputs = [
    freezegun
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ python-dateutil ];
  pyproject = true;
  pythonImportsCheck = [ "beautiful_date" ];

  meta = {
    description = "Simple and beautiful way to create date and datetime objects";
    homepage = "https://github.com/kuzmoyev/beautiful-date";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
