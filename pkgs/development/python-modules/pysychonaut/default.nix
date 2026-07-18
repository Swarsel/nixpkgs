{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
  requests,
  requests-cache,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pysychonaut";
  version = "0.6.0";

  src = fetchPypi {
    inherit version;
    sha256 = "1wgk445gmi0x7xmd8qvnyxy1ka0n72fr6nrhzdm29q6687dqyi7h";
    pname = "PySychonaut";
  };

  preConfigure = ''
    substituteInPlace setup.py --replace-fail "bs4" "beautifulsoup4"
  '';

  # No tests available
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    requests
    requests-cache
    beautifulsoup4
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysychonaut" ];

  meta = {
    description = "Unofficial python api for Erowid, PsychonautWiki and AskTheCaterpillar";
    homepage = "https://github.com/OpenJarbas/PySychonaut";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
