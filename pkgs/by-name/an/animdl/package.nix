{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "animdl";
  version = "1.7.27";

  src = fetchFromGitHub {
    owner = "justfoolingaround";
    repo = "animdl";
    # Using the commit hash because upstream does not have releases. https://github.com/justfoolingaround/animdl/issues/277
    rev = "c7c3b79198e66695e0bbbc576f9d9b788616957f";
    hash = "sha256-kn6vCCFhJNlruxoO+PTHVIwTf1E5j1aSdBhrFuGzUq4=";
  };

  doCheck = true;

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    anchor-kr
    anitopy
    click
    cssselect
    httpx
    lxml
    packaging
    pkginfo
    pycryptodomex
    pyyaml
    regex
    rich
    tqdm
    yarl
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "click"
    "cssselect"
    "httpx"
    "lxml"
    "packaging"
    "pycryptodomex"
    "regex"
    "rich"
    "tqdm"
    "yarl"
  ];

  pythonRemoveDeps = [
    "comtypes" # windows only
  ];

  meta = {
    description = "Highly efficient, powerful and fast anime scraper";
    homepage = "https://github.com/justfoolingaround/animdl";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ passivelemon ];
    mainProgram = "animdl";
  };
}
