{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  pybind11,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "optree";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "metaopt";
    repo = "optree";
    tag = "v${version}";
    hash = "sha256-i/vn9Lo5UiY3+1Mh6FMSMjEyDcs8dtWSL3ESZ8CyHPw=";
  };

  nativeBuildInputs = [
    setuptools
    pybind11
    cmake
  ];

  propagatedBuildInputs = [ typing-extensions ];
  nativeCheckInputs = [ pytestCheckHook ];

  # prevent import failures from pytest
  preCheck = ''
    rm -r optree
  '';

  disabledTests = [
    # Fails because the 'test_treespec' module can't be found
    "test_treespec_pickle_missing_registration"
    # optree import during tests raises CalledProcessError
    "test_warn_deprecated_import"
    "test_import_no_warnings"
    "test_treespec_construct"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "optree" ];

  meta = {
    description = "Optimized PyTree Utilities";
    homepage = "https://github.com/metaopt/optree";
    changelog = "https://github.com/metaopt/optree/releases";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pandapip1 ];
  };
}
