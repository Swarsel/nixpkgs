{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pkginfo2";
  version = "30.1.0";

  src = fetchFromGitHub {
    owner = "aboutcode-org";
    repo = "pkginfo2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M6fJbW1XCe+LKyjIupKnLmVkH582r1+AH44r9JA0Sxg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTestPaths = [
    # disabled in upstream CI: https://github.com/aboutcode-org/pkginfo2/commit/4c9899954a154095aa3289d2a1657257f3f0d0e0
    "tests/wonky/"
    "tests/examples/"
  ];

  disabledTests = [
    # AssertionError
    "test_ctor_w_path"
    "test_ctor_w_egg_info_as_file"
  ];

  # Tries to setup python virtualenv and install dependencies
  dontConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "pkginfo2" ];

  meta = {
    description = "Query metadatdata from sdists, bdists or installed packages";
    homepage = "https://github.com/aboutcode-org/pkginfo2";
    changelog = "https://github.com/aboutcode-org/pkginfo2/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pkginfo2";
  };
})
