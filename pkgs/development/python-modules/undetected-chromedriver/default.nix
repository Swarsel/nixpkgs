{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  looseversion,
  requests,
  selenium,
  setuptools,
  websockets,
}:

buildPythonPackage {
  pname = "undetected-chromedriver";
  version = "3.5.5";

  src = fetchFromGitHub {
    owner = "ultrafunkamsterdam";
    repo = "undetected-chromedriver";
    # Upstream uses the summaries of commits for specifying versions
    rev = "0aa5fbe252370b4cb2b95526add445392cad27ba";
    hash = "sha256-Qe+GrsUPnhjJMDgjdUCloapjj0ggFlm/Dr42WLcmb1o=";
  };

  postPatch = ''
    substituteInPlace undetected_chromedriver/patcher.py \
      --replace-fail \
        "from distutils.version import LooseVersion" \
        "from looseversion import LooseVersion"
  '';

  # No tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    looseversion
    requests
    selenium
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "undetected_chromedriver" ];

  meta = {
    description = "Python library for the custom Selenium ChromeDriver that passes all bot mitigation systems";
    homepage = "https://github.com/ultrafunkamsterdam/undetected-chromedriver";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
}
