{
  lib,
  stdenv,
  buildPythonPackage,
  # tests
  ddt,
  # dependencies
  debtcollector,
  eventlet,
  fetchPypi,
  fixtures,
  iana-etc,
  iso8601,
  libredirect,
  libxcrypt-legacy,
  netaddr,
  oslo-i18n,
  oslotest,
  packaging,
  # build-system
  pbr,
  psutil,
  pyparsing,
  pytz,
  pyyaml,
  qemu-utils,
  setuptools,
  stestr,
  testscenarios,
  tzdata,
}:

buildPythonPackage rec {
  pname = "oslo-utils";
  version = "10.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Ib/Cm7TBzZr7TvdB+445Ro+lSF5gcX9PkPOtPc6KHyI=";
    pname = "oslo_utils";
  };

  postPatch =
    let
      soext = stdenv.hostPlatform.extensions.sharedLibrary;
    in
    ''
      substituteInPlace oslo_utils/secretutils.py \
        --replace-fail "ctypes.util.find_library(\"crypt\")" '"${lib.getLib libxcrypt-legacy}/lib/libcrypt${soext}"'

      # only a small portion of the listed packages are actually needed for running the tests
      # so instead of removing them one by one remove everything
      rm test-requirements.txt
    '';

  nativeCheckInputs = [
    ddt
    eventlet
    fixtures
    libredirect.hook
    oslotest
    pyyaml
    qemu-utils
    stestr
    testscenarios
    tzdata
  ];

  # disabled tests:
  # https://bugs.launchpad.net/oslo.utils/+bug/2054134
  # netaddr default behaviour changed to be stricter
  checkPhase = ''
    echo "nameserver 127.0.0.1" > resolv.conf
    export NIX_REDIRECTS=/etc/protocols=${iana-etc}/etc/protocols:/etc/resolv.conf=$(realpath resolv.conf)

    stestr run -e <(echo "
      oslo_utils.tests.test_netutils.NetworkUtilsTest.test_is_valid_ip
      oslo_utils.tests.test_netutils.NetworkUtilsTest.test_is_valid_ipv4
      oslo_utils.tests.test_eventletutils.EventletUtilsTest.test_event_set_clear_timeout
    ")
  '';

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    debtcollector
    iso8601
    netaddr
    oslo-i18n
    packaging
    psutil
    pyparsing
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "oslo_utils" ];

  meta = {
    description = "Oslo Utility library";
    homepage = "https://github.com/openstack/oslo.utils";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
