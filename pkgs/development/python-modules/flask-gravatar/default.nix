{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  # dependencies
  flask,
  pygments,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-gravatar";
  version = "0.5.0";

  src = fetchPypi {
    inherit version;
    sha256 = "YGZfMcLGEokdto/4Aek+06CIHGyOw0arxk0qmSP1YuE=";
    pname = "Flask-Gravatar";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-tCKkA2io/jhvrh6RhTeEw4AKnIZc9hsqTf2qItUsdjo=";
      # flask 3.0 compat
      url = "https://github.com/zzzsochi/Flask-Gravatar/commit/d74d70d9695c464b602c96c2383d391b38ed51ac.patch";
    })
  ];

  postPatch = ''
    sed -i setup.py \
     -e "s|tests_require=tests_require,||g" \
     -e "s|extras_require=extras_require,||g" \
     -e "s|setup_requires=setup_requires,||g"
    # pep8 is deprecated
    substituteInPlace pytest.ini \
     --replace-fail "--pep8" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pygments
  ];

  build-system = [ setuptools ];
  dependencies = [ flask ];
  pyproject = true;
  pythonImportsCheck = [ "flask_gravatar" ];

  meta = {
    description = "Small and simple integration of gravatar into flask";
    homepage = "https://github.com/zzzsochi/Flask-Gravatar";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ gador ];
  };
}
