{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPythonPackage,
  dbus,
  flit-core,
  pytest,
  pytest-asyncio,
  pytest-trio,
  testpath,
  trio,
}:

buildPythonPackage rec {
  pname = "jeepney";
  version = "0.9";

  src = fetchFromGitLab {
    owner = "takluyver";
    repo = "jeepney";
    tag = version;
    hash = "sha256-d8w/4PtDviTYDHO4EwaVbxlYk7CXtlv7vuR+o4LhfRs=";
  };

  nativeCheckInputs = [
    dbus
    pytest
    pytest-trio
    pytest-asyncio
    testpath
    trio
  ];

  checkPhase = ''
    runHook preCheck

    dbus-run-session --config-file=${dbus}/share/dbus-1/session.conf -- pytest ${lib.optionalString stdenv.hostPlatform.isDarwin "--ignore=jeepney/io/tests"}

    runHook postCheck
  '';

  build-system = [ flit-core ];
  pyproject = true;

  pythonImportsCheck = [
    "jeepney"
    "jeepney.auth"
    "jeepney.io"
    "jeepney.io.asyncio"
    "jeepney.io.blocking"
    "jeepney.io.threading"
    "jeepney.io.trio"
  ];

  meta = {
    description = "Pure Python DBus interface";
    homepage = "https://gitlab.com/takluyver/jeepney";
    changelog = "https://gitlab.com/takluyver/jeepney/-/blob/${src.tag}/docs/release-notes.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
