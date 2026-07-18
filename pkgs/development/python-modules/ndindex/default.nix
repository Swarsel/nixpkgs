{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # tests
  hypothesis,
  # optional
  numpy,
  pytest-cov-stub,
  pytestCheckHook,
  python,
  setuptools,
  sympy,
}:

buildPythonPackage rec {
  pname = "ndindex";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "Quansight-Labs";
    repo = "ndindex";
    tag = version;
    hash = "sha256-rjhCysdhLCAofob7yUL7s65hMju13uotrzJ+aY0stzI=";
  };

  postPatch = ''
    substituteInPlace pytest.ini \
      --replace-fail "--flakes" ""
  '';

  nativeCheckInputs = [
    hypothesis
    pytest-cov-stub
    pytestCheckHook
    sympy
  ]
  ++ optional-dependencies.arrays;

  # fix Hypothesis timeouts
  preCheck = ''
    cd $out

    echo > ${python.sitePackages}/ndindex/tests/conftest.py <<EOF

    import hypothesis

    hypothesis.settings.register_profile(
      "ci",
      deadline=None,
      print_blob=True,
      derandomize=True,
    )
    EOF
  '';

  build-system = [
    cython
    setuptools
  ];

  optional-dependencies.arrays = [ numpy ];
  pyproject = true;

  pytestFlags = [
    "--hypothesis-profile=ci"
  ];

  pythonImportsCheck = [ "ndindex" ];

  meta = {
    description = "Python library for manipulating indices of ndarrays";
    homepage = "https://github.com/Quansight-Labs/ndindex";
    changelog = "https://github.com/Quansight-Labs/ndindex/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
