{
  lib,
  stdenv,
  # propagates
  autobahn,
  buildPythonPackage,
  buildbot,
  # patch
  coreutils,
  msgpack,
  # passthru
  nixosTests,
  # tests
  parameterized,
  psutil,
  # build system
  setuptools,
  twisted,
}:

buildPythonPackage {
  inherit (buildbot) src version;
  pname = "buildbot_worker";

  postPatch = ''
    cd worker
    touch buildbot_worker/py.typed
    substituteInPlace buildbot_worker/scripts/logwatcher.py \
      --replace /usr/bin/tail "${coreutils}/bin/tail"
  '';

  nativeCheckInputs = [
    parameterized
    psutil
  ];

  build-system = [ setuptools ];

  dependencies = [
    autobahn
    msgpack
    twisted
  ];

  pyproject = true;

  passthru.tests = {
    smoke-test = nixosTests.buildbot;
  };

  meta = {
    description = "Buildbot Worker Daemon";
    homepage = "https://buildbot.net/";
    license = lib.licenses.gpl2;
    teams = [ lib.teams.buildbot ];
  };
}
