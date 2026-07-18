{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  kitchen,
  packaging,
  poetry-core,
  poetry-dynamic-versioning,
  python-dateutil,
  pytz,
  taskwarrior2,
}:

buildPythonPackage rec {
  pname = "taskw-ng";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "bergercookie";
    repo = "taskw-ng";
    tag = "v${version}";
    hash = "sha256-KxXLSDvUclQlNbMR+Zzl6tgBrH2QxqjLVoyBK3OiKVU=";
  };

  propagatedBuildInputs = [
    kitchen
    packaging
    python-dateutil
    pytz
  ];

  checkInputs = [ taskwarrior2 ];

  build-system = [
    poetry-core
    poetry-dynamic-versioning
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "packaging"
    "pytz"
  ];

  # TODO: doesn't pass because `can_use` fails and `task --version` seems not to be answering.
  # pythonImportsCheck = [ "taskw_ng" ];
  passthru.skipBulkUpdate = true;

  meta = {
    description = "Module to interact with the Taskwarrior API";
    homepage = "https://github.com/bergercookie/taskw-ng";
    changelog = "https://github.com/bergercookie/taskw-ng/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
}
