{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytz,
  six,
  taskwarrior2,
  tzlocal,
  writeShellScriptBin,
}:

buildPythonPackage rec {
  pname = "tasklib";
  version = "2.5.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XM1zG1JjbdEEV6i42FjLDQJv+qsePnUbr3kb+APjfXs=";
  };

  propagatedBuildInputs = [
    six
    pytz
    tzlocal
  ];

  nativeCheckInputs = [
    taskwarrior2
    # stub
    (writeShellScriptBin "wsl" "true")
  ];

  format = "setuptools";

  meta = {
    description = "Library for interacting with taskwarrior databases";
    homepage = "https://github.com/robgolding/tasklib";
    changelog = "https://github.com/GothenburgBitFactory/tasklib/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ arcnmx ];
    platforms = lib.platforms.all;
  };
}
