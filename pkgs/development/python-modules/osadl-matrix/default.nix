{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  requests,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "osadl-matrix";
  version = "2024.05.23.010555";

  src = fetchFromGitHub {
    owner = "priv-kweihmann";
    repo = "osadl-matrix";
    tag = finalAttrs.version;
    hash = "sha256-vcSaWDX8P07Bj035vGq5dZYO+WkZOod7tTubWygl27k=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  disabledTests = [
    # earlier in the tests, a full license db is cached and used, but these
    # require a different db afterward, but it's not loaded
    "test_compats"
    "test_supported_licenes_size"
    "test_supported_licenses"

    # requires internet access
    "test_license"
  ];

  pyproject = true;

  # Upstream setup.cfg has addopts, requiring pytest-{cov,forked,random-order}.
  # Clearing it is simpler than replicating those plugins, especially since
  # they only affect how tests run.
  pytestFlags = [
    "--override-ini=addopts="
  ];

  pythonImportsCheck = [
    "osadl_matrix"
  ];

  meta = {
    description = "OSADL license compatibility matrix as a CSV";
    homepage = "https://github.com/priv-kweihmann/osadl-matrix";

    license = with lib.licenses; [
      cc-by-40
      unlicense
    ];

    maintainers = with lib.maintainers; [ eljamm ];
    teams = with lib.teams; [ ngi ];
  };
})
