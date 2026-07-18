{
  lib,
  fetchFromGitHub,
  black,
  buildPythonPackage,
  # large-rebuild downstream dependencies and applications
  flask,
  flit-core,
  importlib-metadata,
  magic-wormhole,
  mitmproxy,
  pytestCheckHook,
  typer,
}:

buildPythonPackage rec {
  pname = "click";
  version = "8.3.3";

  src = fetchFromGitHub {
    owner = "pallets";
    repo = "click";
    tag = version;
    hash = "sha256-LcnAI4hyiuaJ4qnFnbAR5Cft/yvW5tAIjY6qc6K/Nrw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];

  disabledTests = [
    # for some reason the tests fail to execute cat, even though they run with less just fine,
    # even adding coreutils to nativeCheckInputs explicitly does not change anything
    "test_echo_via_pager"
    # test fails with filename normalization on zfs
    "test_file_surrogates"
  ];

  pyproject = true;

  passthru.tests = {
    inherit
      black
      flask
      magic-wormhole
      mitmproxy
      typer
      ;
  };

  meta = {
    description = "Create beautiful command line interfaces in Python";

    longDescription = ''
      A Python package for creating beautiful command line interfaces in a
      composable way, with as little code as necessary.
    '';

    homepage = "https://click.palletsprojects.com/";
    changelog = "https://github.com/pallets/click/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
