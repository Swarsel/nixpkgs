{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "decorator";
  version = "5.2.1";

  src = fetchFromGitHub {
    owner = "micheles";
    repo = "decorator";
    tag = version;
    hash = "sha256-UBjZ8LdgJ6iLBjNTlA3up0qAVBqTSZMJt7oEhUo3ZEo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "tests/test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "decorator" ];

  meta = {
    description = "Better living through Python with decorators";
    homepage = "https://github.com/micheles/decorator";
    changelog = "https://github.com/micheles/decorator/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
