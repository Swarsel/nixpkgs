{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  fftw,
  nix-update-script,
  numpy,
  pandas,
  pip,
  pytestCheckHook,
  scikit-learn,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mrsqm";
  version = "4";

  src = fetchFromGitHub {
    owner = "mlgig";
    repo = "mrsqm";
    tag = "r${version}";
    hash = "sha256-59f18zItV3K6tXcg1v1q2Z8HYrQB8T0ntaaqjxeAEbM=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "setup_requires=['pytest-runner']," ""
    substituteInPlace pyproject.toml \
      --replace-fail "numpy==" "numpy>="
  '';

  nativeBuildInputs = [ cython ];
  buildInputs = [ fftw ];

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    pandas
    scikit-learn
    numpy
    pip
  ];

  enabledTestPaths = [
    "tests/mrsqm"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mrsqm" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "v\\.(.*)"
    ];
  };

  meta = {
    description = "MrSQM (Multiple Representations Sequence Miner) is a time series classifier";
    homepage = "https://pypi.org/project/mrsqm";
    changelog = "https://github.com/mlgig/mrsqm/releases/tag/v.${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
}
