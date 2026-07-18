{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  fetchpatch,
  pytest-aiohttp,
  pytest-asyncio_0,
  pytestCheckHook,
  setuptools,
  webtest,
}:

buildPythonPackage rec {
  pname = "webtest-aiohttp";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "sloria";
    repo = "webtest-aiohttp";
    tag = version;
    hash = "sha256-UuAz/k/Tnumupv3ybFR7PkYHwG3kH7M5oobZykEP+ao=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-OKJGajqJLFMkcbGmGfU9G5hCpJaj24Gs363sI0z7YZw=";
      name = "python311-compat.patch";
      url = "https://github.com/sloria/webtest-aiohttp/commit/64e5ab1867ea9ef87901bb2a1a6142566bffc90b.patch";
    })
  ];

  postPatch = ''
    substituteInPlace test_webtest_aiohttp.py \
      --replace-fail '(app, loop)' '(app, event_loop)' \
      --replace-fail 'WebTestApp(app, loop=loop)' 'WebTestApp(app, loop=event_loop)'
  '';

  nativeCheckInputs = [
    pytest-asyncio_0
    pytest-aiohttp
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    webtest
  ];

  pyproject = true;
  pythonImportsCheck = [ "webtest_aiohttp" ];

  meta = {
    description = "Provides integration of WebTest with aiohttp.web applications";
    homepage = "https://github.com/sloria/webtest-aiohttp";
    changelog = "https://github.com/sloria/webtest-aiohttp/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cript0nauta ];
  };
}
