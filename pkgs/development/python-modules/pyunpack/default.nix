{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cabextract,
  easyprocess,
  entrypoint2,
  patool,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyunpack";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "ponty";
    repo = "pyunpack";
    tag = version;
    hash = "sha256-1MAdiX6+u35f6S8a0ZcIIebZE8bbxTy+0TnMohJ7J6s=";
  };

  postPatch = ''
    substituteInPlace pyunpack/__init__.py \
      --replace-fail \
       '_exepath("patool")' \
       '"${lib.getBin patool}/bin/.patool-wrapped"'
  '';

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytestCheckHook
    cabextract
  ];

  dependencies = [
    easyprocess
    entrypoint2
  ];

  disabledTestPaths = [
    # unfree
    "tests/test_rar.py"

    # We get "patool: error: unrecognized arguments: --password 123"
    # The currently packaged version of patool does not support this flag.
    # https://github.com/wummel/patool/issues/114
    # FIXME: Re-enable these once patool is updated
    "tests/test_rarpw.py"
    "tests/test_zippw.py"
  ];

  disabledTests = [
    # pinning test of `--help` sensitive to python version
    "test_help"
  ];

  pyproject = true;
  pytestFlags = [ "-x" ];
  pythonImportsCheck = [ "pyunpack" ];

  meta = {
    description = "Unpack archive files in python";
    homepage = "https://github.com/ponty/pyunpack";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
