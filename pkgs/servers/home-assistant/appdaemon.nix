{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "appdaemon";
  version = "4.5.13";

  src = fetchFromGitHub {
    owner = "AppDaemon";
    repo = "appdaemon";
    tag = version;
    hash = "sha256-uVlrLyj8GZo1T8AKBxpVTPPqUrwxmyMbgaopmEGZiR4=";
  };

  # no tests implemented
  checkPhase = ''
    $out/bin/appdaemon -v | grep -q "${version}"
  '';

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    aiohttp
    aiohttp-jinja2
    astral
    bcrypt
    deepdiff
    feedparser
    iso8601
    paho-mqtt
    pid
    pydantic
    python-dateutil
    python-socketio
    pytz
    pyyaml
    requests
    sockjs
    uvloop
    tomli
    tomli-w
  ];

  pyproject = true;
  pythonRelaxDeps = true;

  meta = {
    description = "Sandboxed Python execution environment for writing automation apps for Home Assistant";
    homepage = "https://github.com/AppDaemon/appdaemon";
    changelog = "https://github.com/AppDaemon/appdaemon/blob/${version}/docs/HISTORY.md";
    license = lib.licenses.mit;
    mainProgram = "appdaemon";
    teams = [ lib.teams.home-assistant ];
  };
}
