{
  lib,
  fetchFromGitHub,
  bashate,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "kolla";
  version = "21.0.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "kolla";
    tag = finalAttrs.version;
    hash = "sha256-wbVaPIvn4jPcb+h5yKhLDmvT6/widfSX2iV+2KNW8pM=";
  };

  postPatch = ''
    substituteInPlace kolla/image/kolla_worker.py \
      --replace-fail "os.path.join(sys.prefix, 'share/kolla')," \
      "os.path.join(PROJECT_ROOT, '../../../share/kolla'),"

    sed -e 's/git_info = .*/git_info = "${finalAttrs.version}"/' -i kolla/version.py
  '';

  # fake version to make pbr.packaging happy
  env.PBR_VERSION = finalAttrs.version;

  nativeCheckInputs = with python3Packages; [
    testtools
    stestr
    oslotest
    hacking
    bashate
  ];

  # Tests output a few exceptions but still succeed
  checkPhase = ''
    runHook preCheck
    stestr run -e <(echo "test_load_ok")
    runHook postCheck
  '';

  postInstall = ''
    cp kolla/template/repos.yaml $out/${python3Packages.python.sitePackages}/kolla/template/
  '';

  build-system = with python3Packages; [
    setuptools
    pbr
  ];

  dependencies = with python3Packages; [
    docker
    jinja2
    oslo-config
    gitpython
    podman
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "hacking"
  ];

  meta = {
    description = "Provides production-ready containers and deployment tools for operating OpenStack clouds";
    homepage = "https://opendev.org/openstack/kolla";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.astro ];
    mainProgram = "kolla-build";
    teams = [ lib.teams.openstack ];
  };
})
