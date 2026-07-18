{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  matplotlib,
  numpy,
  pytestCheckHook,
  scipy,
}:

buildPythonPackage rec {
  pname = "nimfa";
  version = "1.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Oc/yuGhW0Dyoo9nDhZgDTs8adowyX9OnKLuerbjGuRk=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "import imp" "" \
      --replace-fail "os.path.exists('.git')" "True" \
      --replace-fail "GIT_REVISION = git_version()" "GIT_REVISION = 'v${version}'"
  '';

  doCheck = !isPy3k; # https://github.com/marinkaz/nimfa/issues/42

  nativeCheckInputs = [
    matplotlib
    pytestCheckHook
  ];

  dependencies = [
    numpy
    scipy
  ];

  format = "setuptools";
  setuptools = true;

  meta = {
    description = "Nonnegative matrix factorization library";
    homepage = "http://nimfa.biolab.si";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ashgillman ];
  };
}
