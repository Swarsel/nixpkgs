{
  lib,
  fetchFromGitHub,
  # dependencies
  babel,
  buildPythonPackage,
  langcodes,
  # tests
  pytest-httpserver,
  pytestCheckHook,
  # build-system,
  setuptools,
  tld,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "courlan";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "adbar";
    repo = "courlan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hDbeAd/gil6S8zggBjmrDmnW3DMMdRvG1vULuhYA1zc=";
  };

  # Tests try to write to /tmp directly. use $TMPDIR instead.
  postPatch =
    let
      courlanBinPath = "${placeholder "out"}/bin/courlan";
    in
    ''
      substituteInPlace tests/unit_tests.py \
        --replace-fail \
          'assert os.system("courlan --help") == 0' \
          'assert subprocess.run(["${courlanBinPath}", "--help"]).returncode == 0' \
        --replace-fail \
          'courlan_bin = "courlan"' \
          'courlan_bin = "${courlanBinPath}"'
    '';

  nativeCheckInputs = [
    pytest-httpserver
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    babel
    langcodes
    tld
    urllib3
  ];

  # disable tests that require an internet connection
  disabledTests = [ "test_urlcheck" ];
  pyproject = true;
  pythonImportsCheck = [ "courlan" ];

  meta = {
    description = "Clean, filter and sample URLs to optimize data collection";
    homepage = "https://github.com/adbar/courlan";
    changelog = "https://github.com/adbar/courlan/blob/${finalAttrs.src.tag}/HISTORY.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jokatzke ];
    mainProgram = "courlan";
  };
})
