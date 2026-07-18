{
  lib,
  fetchFromGitHub,
  aspectlib,
  buildPythonPackage,
  elasticsearch,
  freezegun,
  gitMinimal,
  mercurial,
  nbmake,
  py-cpuinfo,
  pygal,
  pytest,
  pytestCheckHook,
  pythonAtLeast,
  pythonOlder,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "pytest-benchmark";
  version = "5.2.3";

  src = fetchFromGitHub {
    owner = "ionelmc";
    repo = "pytest-benchmark";
    tag = "v${version}";
    hash = "sha256-qjgP9H3WUYFm1xamOqhGk5YJQv94QfyJvrRoltHJHHc=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    freezegun
    gitMinimal
    mercurial
    nbmake
    pytestCheckHook
    writableTmpDirAsHomeHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export PATH="$out/bin:$PATH"
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ py-cpuinfo ];

  disabledTests = lib.optionals (pythonOlder "3.12") [
    # AttributeError: 'PluginImportFixer' object has no attribute 'find_spec'
    "test_compare_1"
    "test_compare_2"
    "test_regression_checks"
    "test_regression_checks_inf"
    "test_rendering"
  ];

  optional-dependencies = {
    aspect = [ aspectlib ];
    elasticsearch = [ elasticsearch ];

    histogram = [
      pygal
      # FIXME package pygaljs
      setuptools
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pytest_benchmark" ];

  meta = {
    description = "Pytest fixture for benchmarking code";
    homepage = "https://github.com/ionelmc/pytest-benchmark";
    changelog = "https://github.com/ionelmc/pytest-benchmark/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
