{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  decorator,
  matplotlib,
  numpy,
  pytest-cov-stub,
  pytest-mpl,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mir-eval";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "mir-evaluation";
    repo = "mir_eval";
    tag = version;
    hash = "sha256-Dq/kqoTY8YGATsr6MSgfQxkWvFpmH/Pf1pKBLPApylY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-mpl
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    pushd tests
  '';

  postCheck = ''
    popd
  '';

  build-system = [ setuptools ];

  dependencies = [
    decorator
    numpy
    scipy
  ];

  optional-dependencies.display = [ matplotlib ];
  pyproject = true;
  pythonImportsCheck = [ "mir_eval" ];

  meta = {
    description = "Common metrics for common audio/music processing tasks";
    homepage = "https://github.com/craffel/mir_eval";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ carlthome ];
  };
}
