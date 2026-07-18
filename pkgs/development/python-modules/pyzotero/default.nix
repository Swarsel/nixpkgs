{
  lib,
  fetchFromGitHub,
  # dependencies
  bibtexparser,
  buildPythonPackage,
  feedparser,
  httpx,
  pytest-asyncio,
  # tests
  pytest-cov-stub,
  pytestCheckHook,
  python-dateutil,
  pytz,
  # build-system
  uv-build,
  whenever,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyzotero";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "urschrei";
    repo = "pyzotero";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5Ew5u6+a+8wv0scyQ4IOcZWCimEQLbe9OuKBIKrPoXc=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.14,<0.9.0" "uv-build"
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    python-dateutil
    pytz
  ];

  build-system = [
    uv-build
  ];

  dependencies = [
    bibtexparser
    feedparser
    httpx
    whenever
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyzotero" ];

  meta = {
    description = "Python client for the Zotero API";
    homepage = "https://pyzotero.readthedocs.io/en/latest/";
    changelog = "https://github.com/urschrei/pyzotero/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.blueOak100;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    downloadPage = "https://pyzotero.readthedocs.io/en/latest/";
  };
})
