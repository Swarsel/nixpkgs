{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "pytest-fixture-config";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "man-group";
    repo = "pytest-plugins";
    tag = "v${version}";
    hash = "sha256-fLctuuvHVk9GvQB5cTL4/T7GeWzJ2zLJpwZqq9/6C30=";
  };

  postPatch = ''
    cd pytest-fixture-config
  '';

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    pytestCheckHook
    six
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Simple configuration objects for Py.test fixtures. Allows you to skip tests when their required config variables aren’t set";
    homepage = "https://github.com/manahl/pytest-plugins";
    changelog = "https://github.com/man-group/pytest-plugins/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryansydnor ];
  };
}
