{
  lib,
  buildPythonPackage,
  fasteners,
  fetchPypi,
  jinja2,
  nixosTests,
  pbr,
  pytest-mock,
  pytestCheckHook,
  python-jenkins,
  pyyaml,
  setuptools,
  six,
  stevedore,
  testtools,
}:

buildPythonPackage (finalAttrs: {
  pname = "jenkins-job-builder";
  version = "6.4.4";

  # forge at opendev.org does not provide release tarballs
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-7PpCDpe3KLRpt+R/Nu+qxdDxLKWVqTiCPK3j+nNaum8=";
    pname = "jenkins_job_builder";
  };

  postPatch = ''
    export HOME=$(mktemp -d)
  '';

  nativeCheckInputs = [
    pytestCheckHook
    testtools
    pytest-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    pbr
    python-jenkins
    pyyaml
    six
    stevedore
    fasteners
    jinja2
  ];

  pyproject = true;
  passthru.tests = { inherit (nixosTests) jenkins; };

  meta = {
    description = "Jenkins Job Builder is a system for configuring Jenkins jobs using simple YAML files stored in Git";
    homepage = "https://jenkins-job-builder.readthedocs.io/en/latest/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    mainProgram = "jenkins-jobs";
  };
})
