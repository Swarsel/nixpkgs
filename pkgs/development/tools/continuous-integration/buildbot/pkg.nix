{
  lib,
  buildPythonPackage,
  buildbot,
  isPy3k,
  setuptools,
}:

buildPythonPackage {
  inherit (buildbot) src version;
  pname = "buildbot_pkg";

  postPatch = ''
    cd pkg
    # Their listdir function filters out `node_modules` folders.
    # Do we have to care about that with Nix...?
    substituteInPlace buildbot_pkg.py --replace "os.listdir = listdir" ""
  '';

  # No tests
  doCheck = false;
  build-system = [ setuptools ];
  disabled = !isPy3k;
  pyproject = true;
  pythonImportsCheck = [ "buildbot_pkg" ];

  meta = {
    description = "Buildbot Packaging Helper";
    homepage = "https://buildbot.net/";
    license = lib.licenses.gpl2;
    teams = [ lib.teams.buildbot ];
  };
}
