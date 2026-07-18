{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  numpy,
  pytest-cov-stub,
  pytestCheckHook,
  python,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "fast-histogram";
  version = "0.14";

  src = fetchFromGitHub {
    owner = "astrofrog";
    repo = "fast-histogram";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vIzDDzz6e7PXArHdZdSSgShuTjy3niVdGtXqgmyJl1w=";
  };

  nativeCheckInputs = [
    hypothesis
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ numpy ];

  disabledTests = [
    # ValueError
    "test_1d_compare_with_numpy"
  ];

  enabledTestPaths = [ "${placeholder "out"}/${python.sitePackages}" ];
  pyproject = true;
  pythonImportsCheck = [ "fast_histogram" ];

  meta = {
    description = "Fast 1D and 2D histogram functions in Python";
    homepage = "https://github.com/astrofrog/fast-histogram";
    changelog = "https://github.com/astrofrog/fast-histogram/blob/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ifurther ];
  };
})
