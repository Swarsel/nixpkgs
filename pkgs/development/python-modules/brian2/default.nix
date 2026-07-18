{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  jinja2,
  numpy,
  pyparsing,
  pytest,
  pytest-xdist,
  python,
  pythonOlder,
  scipy,
  setuptools,
  setuptools-scm,
  sympy,
}:

buildPythonPackage rec {
  pname = "brian2";
  version = "2.10.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wdIdewkhkjYkGddvyHH+q5/wuz0A6SZdjNQIbMLhG08=";
  };

  patches = [
    ./0001-remove-invalidxyz.patch # invalidxyz are reported as error so I remove it
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "numpy>=2.0.0rc1" "numpy"

    substituteInPlace brian2/codegen/cpp_prefs.py \
      --replace-fail "distutils" "setuptools._distutils"
  '';

  nativeCheckInputs = [
    pytest
    pytest-xdist
  ];

  checkPhase = ''
    runHook preCheck
    # Cython cache lies in home directory
    export HOME=$(mktemp -d)
    cd $HOME && ${python.interpreter} -c "import brian2;assert brian2.test()"
    runHook postCheck
  '';

  build-system = [
    setuptools-scm
  ];

  dependencies = [
    cython
    jinja2
    numpy
    pyparsing
    setuptools
    sympy
    scipy
  ];

  # https://github.com/python/cpython/issues/117692
  disabled = pythonOlder "3.12";
  pyproject = true;

  meta = {
    description = "Clock-driven simulator for spiking neural networks";
    homepage = "https://briansimulator.org/";
    license = lib.licenses.cecill21;
    maintainers = with lib.maintainers; [ jiegec ];
  };
}
