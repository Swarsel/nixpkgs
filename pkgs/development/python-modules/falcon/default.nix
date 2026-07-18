{
  lib,
  fetchFromGitHub,
  # tests
  aiofiles,
  buildPythonPackage,
  cbor2,
  # build
  cython,
  httpx,
  isPyPy,
  msgpack,
  mujson,
  orjson,
  pytest7CheckHook,
  pythonAtLeast,
  pyyaml,
  rapidjson,
  requests,
  setuptools,
  ujson,
  uvicorn,
  websockets,
}:

buildPythonPackage rec {
  pname = "falcon";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "falconry";
    repo = "falcon";
    tag = version;
    hash = "sha256-Vi7J607PsjwxAKYNCiVGxSRYIbKHgrGvRX9Ent3+LQo=";
  };

  nativeCheckInputs = [
    # https://github.com/falconry/falcon/blob/master/requirements/tests
    pytest7CheckHook
    pyyaml
    requests
    rapidjson
    orjson

    # ASGI specific
    aiofiles
    httpx
    uvicorn
    websockets

    # handler specific
    cbor2
    msgpack
    mujson
    ujson
  ];

  preCheck = ''
    export HOME=$TMPDIR
    cp -R tests examples $TMPDIR
    pushd $TMPDIR
  '';

  postCheck = ''
    popd
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ] ++ lib.optionals (!isPyPy) [ cython ];

  disabledTestPaths = [
    # needs a running server
    "tests/asgi/test_asgi_servers.py"
  ]
  ++ lib.optionals (pythonAtLeast "3.12") [
    # ModuleNotFoundError: No module named 'distutils'
    "tests/asgi/test_cythonized_asgi.py"
  ];

  enabledTestPaths = [ "tests" ];
  pyproject = true;

  meta = {
    description = "Ultra-reliable, fast ASGI+WSGI framework for building data plane APIs at scale";
    homepage = "https://falconframework.org/";
    changelog = "https://falcon.readthedocs.io/en/stable/changes/${src.tag}.html";
    license = lib.licenses.asl20;
  };
}
