{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  cryptography,
  curl-cffi,
  frozendict,
  html5lib,
  lxml,
  multitasking,
  numpy,
  pandas,
  peewee,
  platformdirs,
  protobuf,
  pytz,
  requests,
  requests-cache,
  requests-ratelimiter,
  scipy,
  setuptools,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "yfinance";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "ranaroussi";
    repo = "yfinance";
    tag = finalAttrs.version;
    hash = "sha256-5ynbdBys7uTcvsKQB44aoe8PmQgqP28wPtOATcv8I7g=";
  };

  # Tests require internet access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    cryptography
    curl-cffi
    frozendict
    html5lib
    lxml
    multitasking
    numpy
    pandas
    peewee
    platformdirs
    protobuf
    pytz
    requests
    websockets
  ];

  optional-dependencies = {
    nospam = [
      requests-cache
      requests-ratelimiter
    ];

    repair = [ scipy ];
  };

  pyproject = true;
  pythonImportsCheck = [ "yfinance" ];
  pythonRelaxDeps = [ "curl_cffi" ];

  meta = {
    description = "Module to doiwnload Yahoo! Finance market data";
    homepage = "https://github.com/ranaroussi/yfinance";
    changelog = "https://github.com/ranaroussi/yfinance/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
