{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  callPackage,
  configargparse,
  cryptography,
  flask,
  flask-cors,
  flask-login,
  gevent,
  geventhttpclient,
  hatch-vcs,
  hatchling,
  locust-cloud,
  msgpack,
  psutil,
  pyquery,
  pytest,
  pytestCheckHook,
  python,
  pyzmq,
  requests,
  retry,
  tomli,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "locust";
  version = "2.43.1";

  src = fetchFromGitHub {
    owner = "locustio";
    repo = "locust";
    tag = version;
    hash = "sha256-+0B4S524UjvaYl7VTZ1IY7UuBuDjUBqOvjHu0UVOi6A=";
  };

  postPatch = ''
    substituteInPlace locust/test/test_main.py \
      --replace-fail '"locust"' '"${placeholder "out"}/bin/locust"'

    substituteInPlace locust/test/test_log.py \
      --replace-fail '"locust"' '"${placeholder "out"}/bin/locust"'
  '';

  preBuild = ''
    mkdir -p $out/${python.sitePackages}/locust/webui/dist
    ln -sf ${webui}/dist/* $out/${python.sitePackages}/locust/webui/dist
  '';

  # locust's test suite is very flaky, due to heavy reliance on timing-based tests and access to the
  # network.
  doCheck = false;

  nativeCheckInputs = [
    cryptography
    pyquery
    pytestCheckHook
    retry
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    configargparse
    flask
    flask-cors
    flask-login
    gevent
    geventhttpclient
    msgpack
    locust-cloud
    psutil
    pyzmq
    requests
    tomli
    werkzeug
    pytest
  ];

  pyproject = true;
  pythonImportsCheck = [ "locust" ];

  pythonRelaxDeps = [
    # version 0.7.0.dev0 is not considered to be >= 0.6.3
    "flask-login"
    # version 6.0.1 is listed as 0.0.1 in the dependency check and 0.0.1 is not >= 3.0.10
    "flask-cors"
    "requests"
  ];

  webui = callPackage ./webui.nix {
    inherit version;
    src = "${src}/locust/webui";
  };

  meta = {
    description = "Developer-friendly load testing framework";
    homepage = "https://docs.locust.io/";
    changelog = "https://github.com/locustio/locust/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jokatzke ];
  };
}
