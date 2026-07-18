{
  lib,
  stdenv,
  buildPythonPackage,
  cvxopt,
  fetchPypi,
  networkx,
  numpy,
  python,
  pythonOlder,
  scipy,
}:

buildPythonPackage rec {
  pname = "picos";
  version = "2.6.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-869PnpjwxEnrS2Atfk4CzAkn56kJSqU/XXmnSHZZ5DM=";
  };

  postPatch =
    lib.optionalString (pythonOlder "3.12") ''
      substituteInPlace picos/modeling/problem.py \
        --replace-fail "mappingproxy(OrderedDict({'x': <3×1 Real Variable: x>}))" "mappingproxy(OrderedDict([('x', <3×1 Real Variable: x>)]))"
    ''
    # TypeError: '<=' not supported between instances of 'ComplexAffineExpression' and 'float'
    + lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) ''
      rm tests/ptest_quantentr.py
    '';

  # Needed only for the tests
  nativeCheckInputs = [ networkx ];

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} test.py

    runHook postCheck
  '';

  dependencies = [
    numpy
    cvxopt
    scipy
  ];

  format = "setuptools";

  meta = {
    description = "Python interface to conic optimization solvers";
    homepage = "https://gitlab.com/picos-api/picos";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ tobiasBora ];
  };
}
