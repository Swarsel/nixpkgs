{
  lib,
  fetchFromGitHub,
  blinker,
  buildPythonPackage,
  django,
  flake8,
  flask-sqlalchemy,
  mock,
  peewee,
  pytest-cov-stub,
  pytest-django,
  pytestCheckHook,
  six,
  sqlalchemy,
  webtest,
}:

buildPythonPackage rec {
  pname = "nplusone";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "jmcarp";
    repo = "nplusone";
    rev = "v${version}";
    sha256 = "0qdwpvvg7dzmksz3vqkvb27n52lq5sa8i06m7idnj5xk2dgjkdxg";
  };

  postPatch = ''
    substituteInPlace pytest.ini \
      --replace "python_paths" "pythonpath"
  '';

  propagatedBuildInputs = [
    blinker
    six
  ];

  nativeCheckInputs = [
    flake8
    flask-sqlalchemy
    mock
    peewee
    pytest-django
    pytestCheckHook
    pytest-cov-stub
    sqlalchemy
    webtest
  ];

  disabledTests = [
    # Tests are out-dated
    "test_many_to_one"
    "test_many_to_many"
    "test_eager_join"
    "test_eager_subquery"
    "test_eager_subquery_unused"
    "test_many_to_many_raise"
    "test_many_to_many_whitelist_decoy"
    "test_many_to_one_subquery"
    "test_many_to_one_reverse_subquery"
    "test_many_to_many_subquery"
    "test_many_to_many_reverse_subquery"
    "test_profile"
  ];

  format = "setuptools";

  # The tests assume the source code is in an nplusone/ directory. When using
  # the Nix sandbox, it will be in a source/ directory instead, making the
  # tests fail.
  prePatch = ''
    substituteInPlace tests/conftest.py \
      --replace nplusone/tests/conftest source/tests/conftest
  '';

  pythonImportsCheck = [ "nplusone" ];

  meta = {
    description = "Detecting the n+1 queries problem in Python";
    homepage = "https://github.com/jmcarp/nplusone";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cript0nauta ];
    broken = lib.versionAtLeast django.version "4";
  };
}
