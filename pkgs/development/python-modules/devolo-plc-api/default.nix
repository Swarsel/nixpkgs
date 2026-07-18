{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  httpx,
  protobuf,
  pytest-asyncio_0,
  pytest-httpx,
  pytest-mock,
  pytestCheckHook,
  segno,
  setuptools-scm,
  syrupy,
  tenacity,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "devolo-plc-api";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "2Fake";
    repo = "devolo_plc_api";
    tag = "v${version}";
    hash = "sha256-bmZcjvqZwVJzDsdtSbQvJpry2QSSuB6/jOTWG1+jyV4=";
  };

  patches = [
    # Add Python 3.14 support
    (fetchpatch {
      hash = "sha256-oaLYMvRl2Zcum9XkFQ1Dm1/F/BhURLGKrwh6FguVL9Y=";
      url = "https://github.com/2Fake/devolo_plc_api/commit/3b1c167e2df5909910e97bf1626de88b17fb94d1.patch";
    })
    (fetchpatch {
      hash = "sha256-fDGYhjA/tMFKQnEtix1no8Wf+cp9Ph7keXRq1+sH6YA=";
      url = "https://github.com/2Fake/devolo_plc_api/pull/224.patch";
    })
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "protobuf>=4.22.0" "protobuf"
  '';

  nativeCheckInputs = [
    pytest-asyncio_0
    pytest-httpx
    pytest-mock
    pytestCheckHook
    syrupy
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools-scm ];

  dependencies = [
    httpx
    protobuf
    segno
    tenacity
    zeroconf
  ];

  disabledTests = [
    # pytest-httpx compat issue
    "test_wrong_password_type"
  ];

  pyproject = true;
  pythonImportsCheck = [ "devolo_plc_api" ];

  meta = {
    description = "Module to interact with Devolo PLC devices";
    homepage = "https://github.com/2Fake/devolo_plc_api";
    changelog = "https://github.com/2Fake/devolo_plc_api/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
