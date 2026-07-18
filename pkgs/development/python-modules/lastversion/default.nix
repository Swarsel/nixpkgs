{
  lib,
  fetchFromGitHub,
  # install_requires
  appdirs,
  beautifulsoup4,
  buildPythonPackage,
  cachecontrol,
  distro,
  feedparser,
  packaging,
  # nativeCheckInputs
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  requests,
  # nativeBuildInputs
  setuptools,
  tqdm,
  urllib3,
}:

buildPythonPackage rec {
  pname = "lastversion";
  version = "3.6.12";

  src = fetchFromGitHub {
    owner = "dvershinin";
    repo = "lastversion";
    tag = "v${version}";
    hash = "sha256-5losSZnAW16KznXKtH+hy8Ii6j/B5tMOSQFx6Sv3DT0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  # CLI tests expect the output bin/ in PATH
  preCheck = ''
    PATH="$out/bin:$PATH"
  '';

  build-system = [ setuptools ];

  dependencies = [
    appdirs
    beautifulsoup4
    cachecontrol
    distro
    feedparser
    packaging
    python-dateutil
    pyyaml
    requests
    tqdm
    urllib3
  ]
  ++ cachecontrol.optional-dependencies.filecache;

  enabledTestPaths = [
    "tests/test_cli.py"
  ];

  enabledTests = [
    "test_cli_format"
  ];

  pyproject = true;
  pythonImportsCheck = [ "lastversion" ];

  pythonRelaxDeps = [
    "cachecontrol" # Use newer cachecontrol that uses filelock instead of lockfile
    "urllib3" # The cachecontrol and requests incompatibility issue is closed
  ];

  pythonRemoveDeps = [
    "lockfile" # "cachecontrol" now uses filelock
  ];

  meta = {
    description = "Find the latest release version of an arbitrary project";
    homepage = "https://github.com/dvershinin/lastversion";
    changelog = "https://github.com/dvershinin/lastversion/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ShamrockLee ];
    mainProgram = "lastversion";
  };
}
