{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cliff,
  keystoneauth1,
  openstackdocstheme,
  oslo-i18n,
  oslo-serialization,
  oslo-utils,
  pbr,
  requests,
  requests-mock,
  setuptools,
  sphinxHook,
  sphinxcontrib-apidoc,
  stestr,
}:

buildPythonPackage rec {
  pname = "python-barbicanclient";
  version = "7.3.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-barbicanclient";
    tag = version;
    hash = "sha256-SFAldyA/M0rkKb2o6ePp+9ITWrUszyTz5jvCnUadufo=";
  };

  postPatch = ''
    # Disable rsvgconverter not needed to build manpage
    substituteInPlace doc/source/conf.py \
      --replace-fail "'sphinxcontrib.rsvgconverter'," "#'sphinxcontrib.rsvgconverter',"
  '';

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    requests-mock
    stestr
  ];

  checkPhase = ''
    runHook preCheck
    stestr run
    runHook postCheck
  '';

  build-system = [
    openstackdocstheme
    pbr
    setuptools
    sphinxHook
    sphinxcontrib-apidoc
  ];

  dependencies = [
    cliff
    keystoneauth1
    oslo-i18n
    oslo-serialization
    oslo-utils
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "barbicanclient" ];
  sphinxBuilders = [ "man" ];

  meta = {
    description = "Client library for OpenStack Barbican API";
    homepage = "https://opendev.org/openstack/python-barbicanclient";
    license = lib.licenses.asl20;
    mainProgram = "barbican";
    teams = [ lib.teams.openstack ];
  };
}
