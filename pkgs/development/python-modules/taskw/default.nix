{
  lib,
  buildPythonPackage,
  distutils,
  fetchPypi,
  # dependencies
  kitchen,
  # tests
  pytest7CheckHook,
  python-dateutil,
  pytz,
  # build-system
  setuptools,
  # native dependencies
  taskwarrior2,
}:

buildPythonPackage rec {
  pname = "taskw";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-EQm9+b3nqbMqUAejAsh4MD/2UYi2QiWsdKMomkxUi90=";
  };

  patches = [
    ./use-template-for-taskwarrior-install-path.patch
    # Remove when https://github.com/ralphbean/taskw/pull/151 is merged.
    ./support-relative-path-in-taskrc.patch
  ];

  postPatch = ''
    substituteInPlace taskw/warrior.py \
      --replace '@@taskwarrior@@' '${taskwarrior2}'
  '';

  buildInputs = [
    taskwarrior2
  ];

  nativeCheckInputs = [ pytest7CheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    distutils
    kitchen
    python-dateutil
    pytz
  ];

  pyproject = true;

  meta = {
    description = "Python bindings for your taskwarrior database";
    homepage = "https://github.com/ralphbean/taskw";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ pierron ];
  };
}
