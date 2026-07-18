{
  lib,
  buildPythonPackage,
  # optional-dependencies
  coverage,
  fetchPypi,
  fetchpatch,
  # build-system
  setuptools,
  # tests
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "nose2";
  version = "0.15.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-NncPUZ31vs08v+C+5Ku/v5ufa0604DNh0oK378/E8N8=";
  };

  patches = [
    # Starting with Python 3.14, both `-X` and `--xxx` are surrounded
    # by ANSI color codes in the argparse help text.
    (fetchpatch {
      hash = "sha256-OWzBInMI0ef9g0H3muka7J7FP01IZEFkuzJfaku78bI=";
      url = "https://github.com/nose-devs/nose2/commit/2043fdfa264dc04e379e11c227e63a5704cb0185.patch";
    })
  ];

  nativeCheckInputs = [
    unittestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  optional-dependencies = {
    coverage_plugin = [ coverage ];
  };

  pyproject = true;
  pythonImportsCheck = [ "nose2" ];

  meta = {
    description = "Test runner for Python";
    homepage = "https://github.com/nose-devs/nose2";
    changelog = "https://github.com/nose-devs/nose2/blob/${version}/docs/changelog.rst";
    license = lib.licenses.bsd0;
    maintainers = [ ];
    mainProgram = "nose2";
  };
}
