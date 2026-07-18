{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "zope-exceptions";
  version = "6.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.exceptions";
    tag = version;
    hash = "sha256-LLKS/O1sfrHRfEgbb3GO+/hBtIC9CvfNjorqiKTgujo=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  # circular deps
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    zope-interface
  ];

  pyproject = true;
  pythonImportsCheck = [ "zope.exceptions" ];

  meta = {
    description = "Exception interfaces and implementations";
    homepage = "https://pypi.org/project/zope.exceptions/";
    changelog = "https://github.com/zopefoundation/zope.exceptions/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
