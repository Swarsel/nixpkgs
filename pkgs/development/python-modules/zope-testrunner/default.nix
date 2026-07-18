{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  zope-exceptions,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "zope-testrunner";
  version = "8.1";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.testrunner";
    tag = version;
    hash = "sha256-MqlS/VkLAv9M1WtJ6t2nPMZPH+Cz5wfy2VhtCx/Fwmw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  doCheck = false; # custom test modifies sys.path
  build-system = [ setuptools ];

  dependencies = [
    zope-interface
    zope-exceptions
  ];

  pyproject = true;
  pythonImportsCheck = [ "zope.testrunner" ];
  pythonNamespaces = [ "zope" ];

  meta = {
    description = "Flexible test runner with layer support";
    homepage = "https://github.com/zopefoundation/zope.testrunner";
    changelog = "https://github.com/zopefoundation/zope.testrunner/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
    mainProgram = "zope-testrunner";
  };
}
