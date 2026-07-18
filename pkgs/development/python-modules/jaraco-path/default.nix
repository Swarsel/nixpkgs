{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "jaraco-path";
  version = "3.7.2";

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "jaraco.path";
    tag = "v${version}";
    hash = "sha256-uLkNMhB7aeDJ3fF0Ynjd8MD6+CTKKH8vsB5cH9RPcok=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  pyproject = true;
  pythonImportsCheck = [ "jaraco.path" ];

  meta = {
    description = "Miscellaneous path functions";
    homepage = "https://github.com/jaraco/jaraco.path";
    changelog = "https://github.com/jaraco/jaraco.path/blob/${src.tag}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    broken = stdenv.hostPlatform.isDarwin; # pyobjc is missing
  };
}
