{
  lib,
  fetchFromGitHub,
  argon2-cffi,
  bcrypt,
  buildPythonPackage,
  hatch-regex-commit,
  hatchling,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pwdlib";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "frankie567";
    repo = "pwdlib";
    tag = "v${version}";
    hash = "sha256-0ye/CYlDW73Y2HGKjSdk7LniVkQ6OznoO/qnypRCmBQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [
    hatchling
    hatch-regex-commit
  ];

  dependencies = [
    argon2-cffi
    bcrypt
  ];

  pyproject = true;
  pythonImportsCheck = [ "pwdlib" ];

  meta = {
    description = "Modern password hashing for Python";
    homepage = "https://github.com/frankie567/pwdlib";
    changelog = "https://github.com/frankie567/pwdlib/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
