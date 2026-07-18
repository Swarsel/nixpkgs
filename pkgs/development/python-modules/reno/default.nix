{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docutils,
  dulwich,
  git,
  gnupg,
  pbr,
  pyyaml,
  setuptools,
  sphinx,
  stestr,
  testscenarios,
  testtools,
}:

buildPythonPackage (finalAttrs: {
  pname = "reno";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "reno";
    tag = finalAttrs.version;
    hash = "sha256-le9JtE0XODlYhTFsrjxFXG/Weshr+FyN4M4S3BMBLUE=";
  };

  env.PBR_VERSION = finalAttrs.version;

  nativeCheckInputs = [
    # Python packages
    docutils
    sphinx
    stestr
    testtools
    testscenarios

    # Required programs to run all tests
    git
    gnupg
  ];

  checkPhase = ''
    runHook preCheck
    export HOME=$(mktemp -d)
    stestr run -e <(echo "
      # Expects to be run from a git repository
      reno.tests.test_cache.TestCache.test_build_cache_db
      reno.tests.test_semver.TestSemVer.test_major_post_release
      reno.tests.test_semver.TestSemVer.test_major_working_and_post_release
      reno.tests.test_semver.TestSemVer.test_major_working_copy
      reno.tests.test_semver.TestSemVer.test_minor_post_release
      reno.tests.test_semver.TestSemVer.test_minor_working_and_post_release
      reno.tests.test_semver.TestSemVer.test_minor_working_copy
      reno.tests.test_semver.TestSemVer.test_patch_post_release
      reno.tests.test_semver.TestSemVer.test_patch_working_and_post_release
      reno.tests.test_semver.TestSemVer.test_patch_working_copy
      reno.tests.test_semver.TestSemVer.test_same
      reno.tests.test_semver.TestSemVer.test_same_with_note
    ")
    runHook postCheck
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    dulwich
    pbr
    pyyaml
    setuptools
  ];

  postInstallCheck = ''
    $out/bin/reno -h
  '';

  pyproject = true;
  pythonImportsCheck = [ "reno" ];

  meta = {
    description = "Release Notes Manager";
    homepage = "https://docs.openstack.org/reno/latest";
    license = lib.licenses.asl20;
    mainProgram = "reno";
    teams = [ lib.teams.openstack ];
  };
})
