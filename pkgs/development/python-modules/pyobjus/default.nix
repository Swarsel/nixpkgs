{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  clang,
  # build-system
  cython,
  # buildInputs
  libffi,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyobjus";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "kivy";
    repo = "pyobjus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rKMaXvUNdl8/wlDCQPGccQljnaCBSv/P68f7X1xOe0o=";
  };

  buildInputs = [
    libffi
  ];

  nativeCheckInputs = [
    clang
    pytestCheckHook
  ];

  preCheck = ''
    rm -rf pyobjus
    make test_lib
    mkdir -p $out/${python.sitePackages}/objc_classes
    mv objc_classes/test $out/${python.sitePackages}/objc_classes
  '';

  postCheck = ''
    rm -rf $out/${python.sitePackages}/objc_classes/test
  '';

  __structuredAttrs = true;

  build-system = [
    cython
    setuptools
  ];

  disabledTests = [
    # AssertionError: False is not true
    "test_multiple_delegates"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyobjus" ];

  meta = {
    description = "Access Objective-C classes from Python";
    homepage = "https://github.com/kivy/pyobjus";
    changelog = "https://github.com/kivy/pyobjus/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      drupol
    ];

    platforms = lib.platforms.darwin;
  };
})
