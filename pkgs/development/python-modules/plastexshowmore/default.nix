{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  plasTeX,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "plastexshowmore";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "PatrickMassot";
    repo = "plastexshowmore";
    tag = finalAttrs.version;
    hash = "sha256-b45VHHEwFA41FaInDteix56O7KYDzyKiRRSl7heHqEA=";
  };

  build-system = [ setuptools ];
  dependencies = [ plasTeX ];
  pyproject = true;

  meta = {
    description = "PlasTeX plugin for adding navigation buttons";
    homepage = "https://github.com/PatrickMassot/plastexshowmore";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ niklashh ];
  };
})
