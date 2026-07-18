{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  click,
  flit-core,
  freezegun,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "taxi";
  version = "6.3.3";

  src = fetchFromGitHub {
    owner = "sephii";
    repo = "taxi";
    rev = version;
    hash = "sha256-FeAfat5/Dq0y/XHFbZnOEgFix2z+dP5GXvAANLTPFP8=";
  };

  nativeCheckInputs = [
    freezegun
    pytestCheckHook
  ];

  build-system = [ flit-core ];

  dependencies = [
    appdirs
    click
  ];

  pyproject = true;
  pythonImportsCheck = [ "taxi" ];

  meta = {
    description = "Timesheeting made easy";
    homepage = "https://github.com/sephii/taxi/";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ jocelynthode ];
    mainProgram = "taxi";
  };
}
