{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "sentinels";
  version = "1.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-PC9k91QYfBngoaApsUi3TPWN0S7Ce04ZwOXW4itamoY=";
  };

  postPatch = ''
    # https://github.com/vmalloc/sentinels/pull/10
    sed -i "/testpaths/d" pyproject.toml
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  pyproject = true;
  pythonImportsCheck = [ "sentinels" ];

  meta = {
    description = "Various objects to denote special meanings in python";
    homepage = "https://github.com/vmalloc/sentinels/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ gador ];
  };
}
