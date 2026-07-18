{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "khanaa";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "cakimpei";
    repo = "khanaa";
    tag = "v${version}";
    hash = "sha256-QFvvahVEld3BooINeUYJDahZyfh5xmQNtWRLAOdr6lw=";
  };

  patches = [
    ./001-skip-broken-test.patch
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "khanaa" ];

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  meta = {
    description = "Tool to make spelling Thai more convenient";
    homepage = "https://github.com/cakimpei/khanaa";
    changelog = "https://github.com/cakimpei/khanaa/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
