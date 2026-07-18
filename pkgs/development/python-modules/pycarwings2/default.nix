{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  iso8601,
  pycryptodome,
  pytestCheckHook,
  pyyaml,
  requests,
}:

buildPythonPackage rec {
  pname = "pycarwings2";
  version = "2.14";

  src = fetchFromGitHub {
    owner = "filcole";
    repo = "pycarwings2";
    rev = "v${version}";
    hash = "sha256-kqj/NZXqgPUsOnnzMPmIlICHek7RBxksmL3reNBK+bo=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "'pytest-runner'" ""
    substituteInPlace setup.cfg \
      --replace " --flake8 --cov=pycarwings2 --cache-clear --ignore=venv --verbose" ""
  '';

  propagatedBuildInputs = [
    pyyaml
    iso8601
    requests
    pycryptodome
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # Test requires network access
    "test_bad_password"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pycarwings2" ];

  meta = {
    description = "Python library for interacting with the NissanConnect EV";
    homepage = "https://github.com/filcole/pycarwings2";
    changelog = "https://github.com/filcole/pycarwings2/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
