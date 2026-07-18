{
  lib,
  fetchFromGitHub,
  bgpq4,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "arouteserver";
  version = "1.23.2";

  src = fetchFromGitHub {
    owner = "pierky";
    repo = "arouteserver";
    tag = "v${version}";
    hash = "sha256-qPU1eBEAlF6wcI1KEBtSuf0a+pKsqoCN0mtAPjIr+0c=";
  };

  postPatch = ''
    substituteInPlace tests/static/test_irr_queries_failover.py --replace-fail 'bgpq4 -h' '${lib.getExe bgpq4} -h'

    substituteInPlace pierky/arouteserver/builder.py pierky/arouteserver/config/program.py tests/static/test_cfg_program.py \
      --replace-fail '"bgpq4"' '"${lib.getExe bgpq4}"'
  '';

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    requests-mock
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    aggregate6
    jinja2
    pyyaml
    requests
    packaging
    urllib3
    setuptools
  ];

  disabledTests = [
    # disable copyright year check of files
    "current_year"
  ];

  enabledTestPaths = [ "tests/static" ];
  pyproject = true;

  pythonImportsCheck = [
    "pierky"
    "pierky.arouteserver"
  ];

  pythonRelaxDeps = [ "packaging" ];

  meta = {
    description = "Automatically build (and test) feature-rich configurations for BGP route servers";
    homepage = "https://github.com/pierky/arouteserver";
    changelog = "https://github.com/pierky/arouteserver/blob/v${version}/CHANGES.rst";
    license = with lib.licenses; [ gpl3Only ];

    maintainers = with lib.maintainers; [
      marcel
      johannwagner
    ];

    mainProgram = "arouteserver";
  };
}
