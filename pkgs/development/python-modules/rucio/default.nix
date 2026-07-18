{
  lib,
  fetchFromGitHub,
  # dependencies
  alembic,
  argcomplete,
  boto3,
  buildPythonPackage,
  dogpile-cache,
  flask,
  geoip2,
  gfal2-python,
  google-auth,
  jsonschema,
  oic,
  # build-system
  packaging,
  paramiko,
  prometheus-client,
  pymemcache,
  # tests
  pytestCheckHook,
  python-dateutil,
  python-magic,
  pythonAtLeast,
  redis,
  requests,
  rich,
  setuptools,
  sqlalchemy,
  statsd,
  stomp-py,
  tabulate,
  typing-extensions,
  urllib3,
  wheel,
}:

let
  version = "40.4.1";

  src = fetchFromGitHub {
    owner = "rucio";
    repo = "rucio";
    tag = version;
    hash = "sha256-0o4rJbl4GOH0M0sWkNtDqKJgdgrQyCLihao99RVIXqs=";
  };
in
buildPythonPackage {
  inherit version src;
  pname = "rucio";
  doCheck = false; # needs a rucio.cfg

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    packaging
    setuptools
    wheel
  ];

  dependencies = [
    alembic
    argcomplete
    boto3
    dogpile-cache
    flask
    geoip2
    gfal2-python # needed for rucio download
    google-auth
    jsonschema
    oic
    packaging
    paramiko
    prometheus-client
    pymemcache
    python-dateutil
    python-magic
    redis
    requests
    rich
    sqlalchemy
    statsd
    stomp-py
    tabulate
    typing-extensions
    urllib3
  ];

  # future-1.0.0 not supported for interpreter python3.13
  disabled = pythonAtLeast "3.13";
  pyproject = true;
  pythonImportsCheck = [ "rucio" ];
  pythonRelaxDeps = true;
  pythonRemoveDeps = [ "boto" ];

  meta = {
    description = "Tool for Scientific Data Management";
    homepage = "http://rucio.cern.ch/";
    changelog = "https://github.com/rucio/rucio/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ veprbl ];
  };
}
