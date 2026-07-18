{
  lib,
  fetchFromGitHub,
  async-timeout,
  buildPythonPackage,
  fetchpatch,
  flit,
  httpx,
  lxml,
  pytest-asyncio,
  pytest-httpx,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyrmvtransport";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "cgtobi";
    repo = "pyrmvtransport";
    rev = "v${version}";
    hash = "sha256-nFxGEyO+wyRzPayjjv8WNIJ+XIWbVn0dyyjQKHiyr40=";
  };

  patches = [
    # Can be removed with next release, https://github.com/cgtobi/PyRMVtransport/pull/55
    (fetchpatch {
      hash = "sha256-t+GP5VG1S86vVSsisl85ZHBtOqxIi7QS83DA+HgRet4=";
      name = "update-tests.patch";
      url = "https://github.com/cgtobi/PyRMVtransport/commit/fe93b3d9d625f9ccf8eb7b0c39e0ff41c72d2e77.patch";
    })
  ];

  nativeBuildInputs = [ flit ];

  propagatedBuildInputs = [
    async-timeout
    httpx
    lxml
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-httpx
  ];

  disabledTests = [
    # should fail, but times out
    "test__query_rmv_api_fail"
  ];

  pyproject = true;
  pythonImportsCheck = [ "RMVtransport" ];

  meta = {
    description = "Get transport information from opendata.rmv.de";
    homepage = "https://github.com/cgtobi/PyRMVtransport";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
