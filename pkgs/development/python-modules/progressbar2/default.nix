{
  lib,
  buildPythonPackage,
  dill,
  fetchPypi,
  freezegun,
  pytestCheckHook,
  python-utils,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "progressbar2";
  version = "4.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ZmLLYkiG7THrlNr2HidYO1FE68c4Ohe64Hb49PWQiPs=";
  };

  postPatch = ''
    sed -i "/-cov/d" pytest.ini
  '';

  propagatedBuildInputs = [ python-utils ];

  nativeCheckInputs = [
    dill
    freezegun
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "progressbar" ];

  meta = {
    description = "Text progressbar library";
    homepage = "https://progressbar-2.readthedocs.io/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ashgillman ];
  };
}
