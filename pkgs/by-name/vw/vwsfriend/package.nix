{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "vwsfriend";
  version = "0.24.10";

  src = fetchFromGitHub {
    owner = "tillsteinbach";
    repo = "VWsFriend";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k2LHPjV6ndYpPemLlDBp8oi5ner9LG123FwKTRgqNsM=";
  };

  postPatch = ''
    # we don't need pytest-runner, pylint, etc.
    true > setup_requirements.txt

    substituteInPlace requirements.txt \
      --replace-fail psycopg2-binary psycopg2
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies =
    with python3.pkgs;
    [
      weconnect
      hap-python
      pypng
      sqlalchemy
      psycopg2
      requests
      werkzeug
      flask
      flask-login
      flask-caching
      wtforms
      flask-wtf
      flask-sqlalchemy
      alembic
      haversine
    ]
    ++ weconnect.optional-dependencies.Images
    ++ hap-python.optional-dependencies.QRCode;

  pyproject = true;
  pythonRelaxDeps = true;
  sourceRoot = "${finalAttrs.src.name}/vwsfriend";

  meta = {
    description = "VW WeConnect visualization and control";
    homepage = "https://github.com/tillsteinbach/VWsFriend";
    changelog = "https://github.com/tillsteinbach/VWsFriend/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "vwsfriend";
  };
})
