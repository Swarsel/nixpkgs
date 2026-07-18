{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pybugz";
  version = "0.14";

  src = fetchFromGitHub {
    owner = "williamh";
    repo = "pybugz";
    tag = finalAttrs.version;
    hash = "sha256-rhiCQPSh987QEM4aMd3R/7e6l+pm2eJDE7f5LckIuho=";
  };

  # no tests
  doCheck = false;
  build-system = [ python3Packages.flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "bugz" ];

  meta = {
    description = "Command line interface for Bugzilla";
    homepage = "https://github.com/williamh/pybugz";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "bugz";
  };
})
