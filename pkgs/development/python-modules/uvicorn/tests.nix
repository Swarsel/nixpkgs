{
  stdenv,
  a2wsgi,
  buildPythonPackage,
  httpx,
  pytest-mock,
  pytestCheckHook,
  trustme,
  typing-extensions,
  uvicorn,
  watchgod,
  wsproto,
}:

buildPythonPackage {
  inherit (uvicorn) version;
  pname = "uvicorn-tests";
  src = uvicorn.testsout;
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    uvicorn
    httpx
    pytestCheckHook
    pytest-mock
    trustme
    typing-extensions

    # strictly optional dependencies
    a2wsgi
    watchgod
    wsproto
  ]
  ++ uvicorn.optional-dependencies.standard;

  __darwinAllowLocalNetworking = true;

  disabledTests = [
    "test_supported_upgrade_request"
    "test_invalid_upgrade"
    "test_no_server_headers"
    "test_multiple_server_header"
  ];

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
