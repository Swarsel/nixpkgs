{
  lib,
  buildPythonPackage,
  ddt,
  fetchPypi,
  keystoneauth1,
  openstackdocstheme,
  oslo-i18n,
  oslo-serialization,
  oslo-utils,
  pbr,
  prettytable,
  reno,
  requests,
  requests-mock,
  setuptools,
  simplejson,
  sphinxHook,
  stestr,
  stevedore,
}:

buildPythonPackage rec {
  pname = "python-cinderclient";
  version = "9.9.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-aX5NEsJJ85tB7PT6b8uMOMvy1rLYTW9RXtVnuC3NC9E=";
    pname = "python_cinderclient";
  };

  nativeBuildInputs = [
    openstackdocstheme
    reno
    sphinxHook
  ];

  nativeCheckInputs = [
    ddt
    oslo-serialization
    requests-mock
    stestr
  ];

  checkPhase = ''
    runHook preCheck

    #   File "/build/python-cinderclient-9.6.0/cinderclient/client.py", line 196, in request
    # if raise_exc and resp.status_code >= 400:
    #                  ^^^^^^^^^^^^^^^^^^^^^^^
    #
    # TypeError: '>=' not supported between instances of 'Mock' and 'int'
    stestr run -e <(echo "
      cinderclient.tests.unit.test_client.ClientTest.test_keystone_request_raises_auth_failure_exception
      cinderclient.tests.unit.test_client.ClientTest.test_sessionclient_request_method
      cinderclient.tests.unit.test_client.ClientTest.test_sessionclient_request_method_raises_badrequest
      cinderclient.tests.unit.test_client.ClientTest.test_sessionclient_request_method_raises_overlimit
      cinderclient.tests.unit.test_shell.ShellTest.test_password_prompted
      cinderclient.tests.unit.test_shell.TestLoadVersionedActions.test_load_versioned_actions_with_help
    ")

    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    simplejson
    keystoneauth1
    oslo-i18n
    oslo-utils
    pbr
    prettytable
    requests
    stevedore
  ];

  pyproject = true;
  pythonImportsCheck = [ "cinderclient" ];
  sphinxBuilders = [ "man" ];

  meta = {
    description = "OpenStack Block Storage API Client Library";
    homepage = "https://github.com/openstack/python-cinderclient";
    license = lib.licenses.asl20;
    mainProgram = "cinder";
    teams = [ lib.teams.openstack ];
  };
}
