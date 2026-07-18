{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "alerta-server";
  version = "9.0.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-v4+0l5Sx9RTxmNFnKCoKrWFl1xu1JIRZ/kiI6zi/y0I=";
  };

  # We can't run the tests from Nix, because they rely on the presence of a working MongoDB server
  doCheck = false;
  build-system = [ python3.pkgs.setuptools_80 ];

  dependencies = with python3.pkgs; [
    bcrypt
    blinker
    cryptography
    flask
    flask-compress
    flask-cors
    mohawk
    psycopg2
    pyjwt
    pymongo
    pyparsing
    python-dateutil
    pytz
    pyyaml
    requests
    requests-hawk
    sentry-sdk
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "alerta"
  ];

  meta = {
    description = "Alerta Monitoring System server";
    homepage = "https://alerta.io";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "alertad";
  };
})
