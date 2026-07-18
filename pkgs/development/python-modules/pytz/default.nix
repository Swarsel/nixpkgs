{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  tzdata,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytz";
  version = "2026.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-DmC0eynyFXQ3byGP4hq8AJiUojIeoWxnVPPK1ut83Wo=";
  };

  postPatch = ''
    # Use our system-wide zoneinfo dir instead of the bundled one
    rm -rf pytz/zoneinfo
    ln -snvf ${tzdata}/share/zoneinfo pytz/zoneinfo
  '';

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pytz" ];

  unittestFlagsArray = [
    "-s"
    "pytz/tests"
  ];

  meta = {
    description = "World timezone definitions, modern and historical";
    homepage = "https://pythonhosted.org/pytz";
    changelog = "https://launchpad.net/pytz/+announcements";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dotlambda
      jherland
    ];
  };
}
