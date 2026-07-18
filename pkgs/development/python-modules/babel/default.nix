{
  lib,
  buildPythonPackage,
  fetchPypi,
  # tests
  freezegun,
  glibcLocales,
  isPyPy,
  pytestCheckHook,
  pytz,
  # build-system
  setuptools,
  tzdata,
}:

buildPythonPackage rec {
  pname = "babel";
  version = "2.18.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uAuZoUvQhfys+hXJFl9lH7s0BuZsxgOr8RxXUJN8mS0=";
  };

  nativeCheckInputs = [
    freezegun
    glibcLocales
    pytestCheckHook
    # https://github.com/python-babel/babel/issues/988#issuecomment-1521765563
    pytz
  ]
  ++ lib.optionals isPyPy [ tzdata ];

  build-system = [ setuptools ];

  disabledTests = [
    # fails on days switching from and to daylight saving time in EST
    # https://github.com/python-babel/babel/issues/988
    "test_format_time"
  ];

  pyproject = true;
  pythonImportsCheck = [ "babel" ];

  meta = {
    description = "Collection of internationalizing tools";
    homepage = "https://babel.pocoo.org/";
    changelog = "https://github.com/python-babel/babel/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ getchoo ];
    mainProgram = "pybabel";
  };
}
