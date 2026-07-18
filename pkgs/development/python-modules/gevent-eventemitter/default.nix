{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gevent,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "gevent-eventemitter";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "rossengeorgiev";
    repo = "gevent-eventemitter";
    tag = "v${version}";
    hash = "sha256-aW4OsQi3N5yAMdbTd8rxbb2qYMfFJBR4WQFIXvxpiMw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    gevent
  ];

  pyproject = true;

  meta = {
    description = "EventEmitter using gevent";
    homepage = "https://github.com/rossengeorgiev/gevent-eventemitter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ weirdrock ];
    platforms = lib.platforms.linux;
  };
}
