{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pandas,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  pytz,
  scikit-learn,
}:

buildPythonPackage rec {
  pname = "sklearn-compat";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "sklearn-compat";
    repo = "sklearn-compat";
    tag = version;
    hash = "sha256-bziweext3Mqq0Wa9KlX1gp5NpVYX8IpcvS1gTjxQa70=";
  };

  nativeCheckInputs = [
    pandas
    pytestCheckHook
    pytest-cov-stub
    pytest-xdist
    pytz
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    scikit-learn
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sklearn_compat"
  ];

  meta = {
    description = "Ease multi-version support for scikit-learn compatible library";
    homepage = "https://github.com/sklearn-compat/sklearn-compat";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jadewilk ];
  };
}
