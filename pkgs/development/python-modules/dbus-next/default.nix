{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dbus,
  pytest,
  pytest-asyncio,
  pytest-timeout,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dbus-next";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "altdesktop";
    repo = "python-dbus-next";
    tag = "v${version}";
    hash = "sha256-EKEQZFRUe+E65Z6DNCJFL5uCI5kbXrN7Tzd4O0X5Cqo=";
  };

  # Tests are flaky and upstream is no longer active
  doCheck = false;

  nativeCheckInputs = [
    dbus
    pytest
    pytest-asyncio
    pytest-timeout
  ];

  # test_peer_interface hits a timeout
  # test_tcp_connection_with_forwarding fails due to dbus
  # creating unix socket anyway on v1.14.4
  checkPhase = ''
    runHook preCheck
    dbus-run-session --config-file=${dbus}/share/dbus-1/session.conf \
      ${python.interpreter} -m pytest -sv \
      -k "not test_peer_interface and not test_tcp_connection_with_forwarding"
    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Zero-dependency DBus library for Python with asyncio support";
    homepage = "https://github.com/altdesktop/python-dbus-next";
    changelog = "https://github.com/altdesktop/python-dbus-next/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
