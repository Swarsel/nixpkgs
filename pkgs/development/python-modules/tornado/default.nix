{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # for passthru.tests
  distributed,
  jupyter-server,
  jupyterlab,
  matplotlib,
  mitmproxy,
  pytest-tornado,
  pytest-tornasync,
  pytestCheckHook,
  pyzmq,
  setuptools,
  sockjs-tornado,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "tornado";
  version = "6.5.7";

  src = fetchFromGitHub {
    owner = "tornadoweb";
    repo = "tornado";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iE0Tf95zmPoZJhw7FDLzTmv8HaWds3ZU5xzZSMvxFH4=";
  };

  # To allow tests to pass on slower/high-load machines
  env.ASYNC_TEST_TIMEOUT = 30;
  nativeCheckInputs = [ pytestCheckHook ];
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  disabledTestPaths = [
    # additional tests that have extra dependencies, run slowly, or produce more output than a simple pass/fail
    # https://github.com/tornadoweb/tornado/blob/v6.2.0/maint/test/README
    "maint/test"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tornado" ];

  passthru.tests = {
    inherit
      distributed
      jupyter-server
      jupyterlab
      matplotlib
      mitmproxy
      pytest-tornado
      pytest-tornasync
      pyzmq
      sockjs-tornado
      urllib3
      ;
  };

  meta = {
    description = "Web framework and asynchronous networking library";
    homepage = "https://www.tornadoweb.org/";
    changelog = "https://www.tornadoweb.org/en/stable/releases/${finalAttrs.src.tag}.html";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
