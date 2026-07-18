{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  colorcet,
  flaky,
  # build-system
  hatch-vcs,
  hatchling,
  numpy,
  pandas,
  panel,
  param,
  pytest-asyncio,
  # tests
  pytestCheckHook,
  pyviz-comms,
}:

buildPythonPackage rec {
  pname = "holoviews";
  version = "1.22.1";

  src = fetchFromGitHub {
    owner = "holoviz";
    repo = "holoviews";
    tag = "v${version}";
    hash = "sha256-rZZQgM8gchWTsgA47BVWblzWiWMuHK2vAZD/1Z8BHAk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace '"ignore:No data was collected:coverage.exceptions.CoverageWarning",' ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    flaky
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    colorcet
    numpy
    pandas
    panel
    param
    pyviz-comms
  ];

  disabledTests = [
    # All the below fail due to some change in flaky API
    "test_periodic_param_fn_non_blocking"
    "test_callback_cleanup"
    "test_poly_edit_callback"
    "test_launch_server_with_complex_plot"
    "test_launch_server_with_stream"
    "test_launch_simple_server"
    "test_server_dynamicmap_with_dims"
    "test_server_dynamicmap_with_stream"
    "test_server_dynamicmap_with_stream_dims"

    # ModuleNotFoundError: No module named 'param'
    "test_no_blocklist_imports"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Fails due to font rendering differences
    "test_categorical_axis_fontsize_both"
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::FutureWarning"
  ];

  pythonImportsCheck = [ "holoviews" ];

  meta = {
    description = "Python data analysis and visualization seamless and simple";
    homepage = "https://www.holoviews.org/";
    changelog = "https://github.com/holoviz/holoviews/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "holoviews";
  };
}
