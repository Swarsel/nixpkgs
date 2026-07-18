{
  lib,
  stdenv,
  fetchFromGitHub,
  aiofile,
  brotli,
  brotlicffi,
  buildPythonPackage,
  h11,
  hatchling,
  isPyPy,
  jh2,
  pytest-asyncio,
  pytest-rerunfailures,
  pytest-timeout,
  pytestCheckHook,
  python-socks,
  pythonOlder,
  qh3,
  tornado,
  trustme,
  wsproto,
  zstandard,
}:

buildPythonPackage rec {
  pname = "urllib3-future";
  version = "2.22.901";

  src = fetchFromGitHub {
    owner = "jawah";
    repo = "urllib3.future";
    tag = version;
    hash = "sha256-SP6C6xF9McRbmCAfARKrFVSxKRkNZvs7fLdcR9pIEyM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "''''ignore:.*but not measured.*:coverage.exceptions.CoverageWarning''''," "" \
      --replace-fail "''''ignore:.*No data was collected.*:coverage.exceptions.CoverageWarning''''," ""
  '';

  # prevents installing a urllib3 module and thereby shadow the urllib3 package
  env.URLLIB3_NO_OVERRIDE = "true";
  # PermissionError: [Errno 1] Operation not permitted
  doCheck = !stdenv.buildPlatform.isDarwin;

  nativeCheckInputs = [
    aiofile
    pytest-asyncio
    pytest-rerunfailures
    pytest-timeout
    pytestCheckHook
    tornado
    trustme
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ hatchling ];

  dependencies = [
    h11
    jh2
    qh3
  ];

  disabledTestPaths = [
    # test connects to the internet
    "test/contrib/test_resolver.py::test_url_resolver"
  ];

  optional-dependencies = {
    brotli = [ (if isPyPy then brotlicffi else brotli) ];
    qh3 = [ qh3 ];
    secure = [ ];
    socks = [ python-socks ];
    ws = [ wsproto ];
    zstd = lib.optionals (pythonOlder "3.14") [ zstandard ];
  };

  pyproject = true;
  pythonImportsCheck = [ "urllib3_future" ];

  meta = {
    description = "Powerful HTTP 1.1, 2, and 3 client with both sync and async interfaces";
    homepage = "https://github.com/jawah/urllib3.future";
    changelog = "https://github.com/jawah/urllib3.future/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
