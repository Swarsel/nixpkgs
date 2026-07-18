{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  asgi-csrf,
  asgiref,
  beautifulsoup4,
  buildPythonPackage,
  click,
  click-default-group,
  flexcache,
  flexparser,
  httpx,
  hupper,
  itsdangerous,
  janus,
  jinja2,
  mergedeep,
  platformdirs,
  pluggy,
  pytest-asyncio,
  pytest-timeout,
  pytestCheckHook,
  pyyaml,
  setuptools,
  trustme,
  typing-extensions,
  uvicorn,
}:

buildPythonPackage rec {
  pname = "datasette";
  version = "0.65.2";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "datasette";
    tag = version;
    hash = "sha256-9ZMQ9xpWalkM4Ymoc/IA0ct+0r8ht1TxW5qPlVMFspE=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace '"pytest-runner"' ""
  '';

  nativeCheckInputs = [
    aiohttp
    beautifulsoup4
    pytest-asyncio
    pytest-timeout
    pytestCheckHook
    trustme
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    asgi-csrf
    asgiref
    click
    click-default-group
    flexcache
    flexparser
    httpx
    hupper
    itsdangerous
    janus
    jinja2
    mergedeep
    platformdirs
    pluggy
    pyyaml
    setuptools
    typing-extensions
    uvicorn
  ];

  disabledTests = [
    "facet"
    "_invalid_database" # checks error message when connecting to invalid database
  ];

  # takes 30-180 mins to run entire test suite, not worth the CPU resources, slows down reviews
  # with pytest-xdist, it still takes around 10 mins with 32 cores
  # just run the csv tests, as this should give some indictation of correctness
  enabledTestPaths = [
    "tests/test_csv.py"
  ];

  pyproject = true;

  pytestFlags = [
    # datasette/app.py:14: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [
    "datasette"
    "datasette.cli"
    "datasette.app"
    "datasette.database"
    "datasette.renderer"
    "datasette.tracer"
    "datasette.plugins"
  ];

  pythonRemoveDeps = [
    "pip"
    "setuptools"
  ];

  meta = {
    description = "Multi-tool for exploring and publishing data";
    homepage = "https://datasette.io/";
    changelog = "https://github.com/simonw/datasette/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "datasette";
  };
}
