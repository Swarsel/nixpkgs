{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  pytest-randomly,
  pytestCheckHook,
  scikit-learn,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mlrose";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "gkhayes";
    repo = "mlrose";
    rev = "v${version}";
    sha256 = "1dn43k3rcypj58ymcj849b37w66jz7fphw8842v6mlbij3x0rxfl";
  };

  patches = [
    # Fixes compatibility with scikit-learn 0.24.1
    (fetchpatch {
      sha256 = "1nivz3bn21nd21bxbcl16a6jmy7y5j8ilz90cjmd0xq4v7flsahf";
      url = "https://github.com/gkhayes/mlrose/pull/55/commits/19caf8616fc194402678aa67917db334ad02852a.patch";
    })
  ];

  postPatch = ''
    substituteInPlace setup.py --replace-fail sklearn scikit-learn
  '';

  nativeCheckInputs = [
    pytest-randomly
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ scikit-learn ];

  disabledTests = [
    # mimic optimizer fails to converge under current numpy
    "test_mimic_discrete_max_fast"
  ];

  pyproject = true;
  # Fix random seed during tests
  pytestFlags = [ "--randomly-seed=0" ];
  pythonImportsCheck = [ "mlrose" ];

  meta = {
    description = "Machine Learning, Randomized Optimization and SEarch";
    homepage = "https://github.com/gkhayes/mlrose";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
