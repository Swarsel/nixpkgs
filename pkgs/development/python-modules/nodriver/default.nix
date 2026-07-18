{
  lib,
  buildPythonPackage,
  deprecated,
  fetchPypi,
  mss,
  setuptools,
  websockets,
}:

buildPythonPackage rec {
  pname = "nodriver";
  version = "0.50.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JMpojYZG74/61cjOZYBOXnZxp3mtJqJNdvZGXVZmxjE=";
  };

  patches = [
    # https://github.com/ultrafunkamsterdam/nodriver/pull/36
    ./python-3.14-network-py-encoding.patch
  ];

  # no tests in upstream
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    deprecated
    mss
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "nodriver" ];

  meta = {
    description = "Web automation framework which can bypass bot detection";

    longDescription = ''
      Successor of Undetected-Chromedriver. Providing a blazing fast framework for web
      automation, webscraping, bots and any other creative ideas which are normally
      hindered by annoying anti bot systems like Captcha / CloudFlare / Imperva / hCaptcha
    '';

    homepage = "https://github.com/ultrafunkamsterdam/nodriver";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      liammurphy14
      toasteruwu
    ];
  };
}
