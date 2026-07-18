{
  lib,
  fetchFromGitHub,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-notify";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "phijor";
    repo = "mopidy-notify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oAOJvonDDmtpmzgu8Y+BczuLYpfrVlwASIFOW7rhZ94=";
  };

  nativeBuildInputs = [
    pythonPackages.pytestCheckHook
  ];

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
    pythonPackages.pydbus
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_notify" ];
  pythonRelaxDeps = [ "pykka" ];

  meta = {
    description = "Mopidy extension for showing desktop notifications on track change";
    homepage = "https://github.com/phijor/mopidy-notify";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.nim65s ];
  };
})
