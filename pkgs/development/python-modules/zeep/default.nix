{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  attrs,
  buildPythonPackage,
  defusedxml,
  freezegun,
  httpx,
  isodate,
  lxml,
  mock,
  packaging,
  platformdirs,
  pretend,
  pytest-asyncio,
  pytest-httpx,
  pytestCheckHook,
  pytz,
  requests,
  requests-file,
  requests-mock,
  requests-toolbelt,
  setuptools,
  xmlsec,
}:

buildPythonPackage rec {
  pname = "zeep";
  version = "4.3.3";

  src = fetchFromGitHub {
    owner = "mvantellingen";
    repo = "python-zeep";
    tag = version;
    hash = "sha256-0Mzvb86f1r07PCJqTy9CGUq9Zk2PtAsFfd3SmFlOayk=";
  };

  nativeCheckInputs = [
    aiohttp
    aioresponses
    freezegun
    mock
    pretend
    pytest-asyncio
    pytest-httpx
    pytestCheckHook
    requests-mock
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export HOME=$TMPDIR
  '';

  build-system = [ setuptools ];

  dependencies = [
    attrs
    defusedxml
    isodate
    lxml
    packaging
    platformdirs
    pytz
    requests
    requests-file
    requests-toolbelt
  ];

  disabledTests = [
    # Failed: External connections not allowed during tests.
    "test_has_expired"
    "test_has_not_expired"
    "test_memory_cache_timeout"
    "test_bytes_like_password_digest"
    "test_password_digest"
  ];

  optional-dependencies = {
    async = [ httpx ];
    xmlsec = [ xmlsec ];
  };

  pyproject = true;
  pythonImportsCheck = [ "zeep" ];

  meta = {
    description = "Python SOAP client";
    homepage = "http://docs.python-zeep.org";
    changelog = "https://github.com/mvantellingen/python-zeep/releases/tag/${src.tag}";
    license = lib.licenses.mit;
  };
}
