{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
  zope-component,
  zope-event,
  zope-interface,
  zope-testing,
}:

buildPythonPackage rec {
  pname = "zope-lifecycleevent";
  version = "6.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.lifecycleevent";
    tag = version;
    hash = "sha256-HgxOUseRYc+mkwESUDqauoH2D2E4PL8XxM1C0FC35w8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [
    unittestCheckHook
    zope-component
    zope-testing
  ];

  build-system = [ setuptools ];

  dependencies = [
    zope-event
    zope-interface
  ];

  pyproject = true;

  pythonImportsCheck = [
    "zope.lifecycleevent"
    "zope.interface"
  ];

  pythonNamespaces = [ "zope" ];
  unittestFlagsArray = [ "src/zope/lifecycleevent" ];

  meta = {
    description = "Object life-cycle events";
    homepage = "https://github.com/zopefoundation/zope.lifecycleevent";
    changelog = "https://github.com/zopefoundation/zope.lifecycleevent/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
