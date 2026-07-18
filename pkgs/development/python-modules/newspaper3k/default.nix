{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  feedparser,
  fetchPypi,
  lxml,
  lxml-html-clean,
  pillow,
  python-dateutil,
  requests,
  tldextract,
}:

buildPythonPackage rec {
  pname = "newspaper3k";
  version = "0.2.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-nxvT4ftI9ADHFav4dcx7Cme33c2H9Qya7rj8u72QBPs=";
  };

  dependencies = [
    feedparser
    requests
    pillow
    tldextract
    lxml
    lxml-html-clean
    beautifulsoup4
    python-dateutil
  ];

  format = "setuptools";
  pythonImportsCheck = [ "newspaper" ];

  meta = {
    description = "Simplified python article discovery & extraction";
    homepage = "https://pypi.org/project/newspaper3k";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
