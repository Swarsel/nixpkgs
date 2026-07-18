{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flaky,
  hypothesis,
  pytest-xdist,
  pytest7CheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "coverage";
  version = "7.14.1";

  src = fetchFromGitHub {
    owner = "coveragepy";
    repo = "coveragepy";
    tag = finalAttrs.version;
    hash = "sha256-3/Q6TQfoZNM7bHjviw/C70i2ZgjobHnynmqX9qvreYQ=";
  };

  nativeCheckInputs = [
    flaky
    hypothesis
    pytest-xdist
    pytest7CheckHook
  ];

  preCheck = ''
    export PATH="$PATH:$out/bin"
    # import from $out
    rm -r coverage
  '';

  build-system = [ setuptools ];

  disabledTests = [
    # tests expect coverage source to be there
    "test_all_our_source_files"
    "test_real_code_regions"
  ];

  pyproject = true;

  meta = {
    description = "Code coverage measurement for Python";
    homepage = "https://github.com/coveragepy/coveragepy";
    changelog = "https://github.com/coveragepy/coveragepy/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
