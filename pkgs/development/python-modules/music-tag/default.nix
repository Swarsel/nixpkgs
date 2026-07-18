{
  lib,
  buildPythonPackage,
  fetchPypi,
  mutagen,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "music-tag";
  version = "0.4.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Cqtubu2o3w9TFuwtIZC9dFYbfgNWKrCRzo1Wh828//Y=";
  };

  propagatedBuildInputs = [ mutagen ];
  # Tests fail: ModuleNotFoundError: No module named '_test_common'
  doCheck = false;
  checkInputs = [ pytestCheckHook ];
  enabledTestPaths = [ "test" ];
  format = "setuptools";
  pythonImportsCheck = [ "music_tag" ];

  meta = {
    description = "Simple interface to edit audio file metadata";
    homepage = "https://github.com/KristoforMaynard/music-tag";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
  };
}
