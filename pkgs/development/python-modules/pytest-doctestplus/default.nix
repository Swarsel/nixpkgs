{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitMinimal,
  numpy,
  packaging,
  pytest,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pytest-doctestplus";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "scientific-python";
    repo = "pytest-doctestplus";
    tag = "v${version}";
    hash = "sha256-64I0K0+yYU1omGkVgfxeD9r9s9yHp0ik1HAsEc1NNtA=";
  };

  postPatch = ''
    substituteInPlace pytest_doctestplus/plugin.py \
      --replace-fail '"git"' '"${lib.getExe gitMinimal}"'
  '';

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    numpy
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    packaging
  ];

  disabledTests = [
    # ERROR: usage: __main__.py [options] [file_or_dir] [file_or_dir] [...]
    # __main__.py: error: unrecognized arguments: --remote-data
    "test_remote_data_url"
    "test_remote_data_float_cmp"
    "test_remote_data_ignore_whitespace"
    "test_remote_data_ellipsis"
    "test_remote_data_requires"
    "test_remote_data_ignore_warnings"
    "test_remote_data_all"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_doctestplus" ];

  meta = {
    description = "Pytest plugin with advanced doctest features";
    homepage = "https://astropy.org";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
