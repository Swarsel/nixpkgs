{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docutils,
  flask,
  flask-compress,
  flask-restx,
  flask-xml-rpc-re,
  importlib-metadata,
  ipy,
  # indirect deps omitted: jinja2/markupsafe/werkzeug,
  parsedatetime,
  psutil,
  psycopg2,
  pyjwt,
  pyparsing,
  python-dateutil,
  # optional deps
  ## ldap
  python-ldap,
  pytz,
  requests,
  # build deps
  setuptools,
  tornado,
  # dependencies
  zipp,
}:

buildPythonPackage rec {
  pname = "nipap";
  version = "0.32.7";

  src = fetchFromGitHub {
    owner = "SpriteLink";
    repo = "NIPAP";
    tag = "v${version}";
    hash = "sha256-FnCHW/yEhWtx+2fU+G6vxz50lWC7WL3cYKYOQzmH8zs=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'docutils==0.20.1' 'docutils'
  '';

  doCheck = false; # tests require nose, /etc/nipap/nipap.conf and a running nipapd

  build-system = [
    setuptools
    docutils
  ];

  dependencies = [
    zipp
    importlib-metadata
    flask
    flask-compress
    flask-xml-rpc-re
    flask-restx
    requests
    ipy
    # indirect deps omitted: jinja2/markupsafe/werkzeug
    parsedatetime
    psutil
    psycopg2
    pyparsing
    python-dateutil
    pytz
    pyjwt
    tornado
  ];

  optional-dependencies = {
    ldap = [ python-ldap ];
  };

  pyproject = true;
  pythonRelaxDeps = true; # deps are tightly specified by upstream
  sourceRoot = "${src.name}/nipap";

  meta = {
    description = "Neat IP Address Planner";

    longDescription = ''
      NIPAP is the best open source IPAM in the known universe,
      challenging classical IP address management (IPAM) systems in many areas.
    '';

    homepage = "https://github.com/SpriteLink/NIPAP";
    changelog = "https://github.com/SpriteLink/NIPAP/releases/tag/v${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      lukegb
    ];

    platforms = lib.platforms.all;
  };
}
