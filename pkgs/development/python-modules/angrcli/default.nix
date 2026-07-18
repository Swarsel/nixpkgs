{
  lib,
  stdenv,
  fetchFromGitHub,
  angr,
  buildPythonPackage,
  cmd2,
  coreutils,
  pygments,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "angrcli";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "fmagin";
    repo = "angr-cli";
    tag = "v${version}";
    hash = "sha256-egu7jlEk8/i36qQMHztGr959sBt9d5crW8mj6+sKaHI=";
  };

  postPatch = ''
    substituteInPlace tests/test_derefs.py \
      --replace-fail "/bin/ls" "${coreutils}/bin/ls"
  '';

  nativeCheckInputs = [
    coreutils
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    angr
    cmd2
    pygments
  ];

  disabledTests = lib.optionals (!stdenv.hostPlatform.isx86) [
    # expects the x86 register "rax" to exist
    "test_cc"
    "test_loop"
    "test_max_depth"
  ];

  pyproject = true;
  pythonImportsCheck = [ "angrcli" ];

  meta = {
    description = "Python modules to allow easier interactive use of angr";
    homepage = "https://github.com/fmagin/angr-cli";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
