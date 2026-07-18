{
  lib,
  fetchFromGitHub,
  blinker,
  brotli,
  buildPythonPackage,
  certifi,
  gunicorn,
  h2,
  httpbin,
  hyperframe,
  kaitaistruct,
  pyasn1,
  pyopenssl,
  pyparsing,
  pysocks,
  pytestCheckHook,
  selenium,
  setuptools,
  wsproto,
  zstandard,
}:

buildPythonPackage rec {
  pname = "selenium-wire";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "wkeeling";
    repo = "selenium-wire";
    tag = version;
    hash = "sha256-KgaDxHS0dAK6CT53L1qqx1aORMmkeaiXAUtGC82hiIQ=";
  };

  nativeCheckInputs = [
    gunicorn
    httpbin
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    blinker
    brotli
    certifi
    h2
    hyperframe
    kaitaistruct
    pyasn1
    pyopenssl
    pyparsing
    pysocks
    selenium
    wsproto
    zstandard
  ];

  disabledTestPaths = [
    # Don't run End2End tests
    "tests/end2end/test_end2end.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "seleniumwire" ];

  meta = {
    description = "Extends Selenium's Python bindings to give you the ability to inspect requests made by the browser";
    homepage = "https://github.com/wkeeling/selenium-wire";
    changelog = "https://github.com/wkeeling/selenium-wire/blob/${version}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    broken = lib.versionAtLeast blinker.version "1.8";
  };
}
