{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  termcolor,
}:

buildPythonPackage rec {
  pname = "pytest-sugar";
  version = "1.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-c7i2UWPr8Q+fZx76ue7T1W8g0spovag/pkdAqSwI9l0=";
  };

  postPatch = ''
    # pytest 9 compat
    substituteInPlace test_sugar.py \
      --replace-fail "startdir" "start_path"
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    termcolor
  ];

  pyproject = true;

  meta = {
    description = "Plugin that changes the default look and feel of pytest";
    homepage = "https://github.com/Frozenball/pytest-sugar";
    changelog = "https://github.com/Teemu/pytest-sugar/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
