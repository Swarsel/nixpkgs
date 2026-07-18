{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-httpserver,
  pytest-scim2-server,
  pytestCheckHook,
  pythonOlder,
  scim2-client,
  scim2-models,
  uv-build,
}:

buildPythonPackage rec {
  pname = "scim2-tester";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "python-scim";
    repo = "scim2-tester";
    tag = version;
    hash = "sha256-mWlIZC7080YABBWT2oNDVyrV5YrRzkzCUSZZBK7NNVM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'uv_build>=0.8.9,<0.9.0' 'uv_build'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-scim2-server
    pytest-httpserver
  ]
  ++ optional-dependencies.httpx;

  build-system = [ uv-build ];

  dependencies = [
    scim2-client
    scim2-models
  ];

  optional-dependencies.httpx = scim2-client.optional-dependencies.httpx;
  pyproject = true;
  pythonImportsCheck = [ "scim2_tester" ];

  meta = {
    description = "SCIM RFCs server compliance checker";
    homepage = "https://scim2-tester.readthedocs.io/";
    changelog = "https://github.com/python-scim/scim2-tester/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
