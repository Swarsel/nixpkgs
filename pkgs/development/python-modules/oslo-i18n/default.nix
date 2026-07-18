{
  lib,
  buildPythonPackage,
  fetchPypi,
  oslotest,
  pbr,
  setuptools,
  stestr,
  testscenarios,
}:

buildPythonPackage rec {
  pname = "oslo-i18n";
  version = "6.8.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-oLTGTBOWhp1xRNymCtl8frAo949h+RxwB1MSOAUZl98=";
    pname = "oslo_i18n";
  };

  postPatch = ''
    # only a small portion of the listed packages are actually needed for running the tests
    # so instead of removing them one by one remove everything
    rm test-requirements.txt
  '';

  nativeCheckInputs = [
    oslotest
    stestr
    testscenarios
  ];

  checkPhase = ''
    runHook preCheck

    stestr run -e <(echo "
    # list is not deduped
    oslo_i18n.tests.test_gettextutils.GettextTest.test_get_available_languages
    ")

    runHook postCheck
  '';

  build-system = [
    pbr
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "oslo_i18n" ];

  meta = {
    description = "Oslo i18n library";
    homepage = "https://github.com/openstack/oslo.i18n";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
