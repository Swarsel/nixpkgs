{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  beautifulsoup4,
  buildPythonPackage,
  httpx,
  multidict,
  # build-system
  poetry-core,
  # tests
  pytest-asyncio,
  pytestCheckHook,
  typer,
  yarl,
}:

buildPythonPackage rec {
  pname = "authcaptureproxy";
  version = "1.3.7";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "auth_capture_proxy";
    tag = "v${version}";
    hash = "sha256-3osyh4Er0bZ8dvOtDV1w66zOWuzECIWeL8M90gqi+D8=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    aiohttp
    beautifulsoup4
    httpx
    multidict
    typer
    yarl
  ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  disabledTests = [
    # test fails with frequency 1/200
    # https://github.com/alandtse/auth_capture_proxy/issues/25
    "test_return_timer_countdown_refresh_html"
    # AttributeError: 'NoneType' object has no attribute 'get'
    "test_replace_empty_action_urls"
  ];

  pyproject = true;
  pythonImportsCheck = [ "authcaptureproxy" ];

  meta = {
    description = "Proxy to capture authentication information from a webpage";
    homepage = "https://github.com/alandtse/auth_capture_proxy";
    changelog = "https://github.com/alandtse/auth_capture_proxy/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      graham33
      hexa
    ];

    mainProgram = "auth_capture_proxy";
  };
}
