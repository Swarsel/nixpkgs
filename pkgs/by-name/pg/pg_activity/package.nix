{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pg_activity";
  version = "3.6.2";

  src = fetchFromGitHub {
    owner = "dalibo";
    repo = "pg_activity";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-W5R521eyJjblCE5NG546ItMZo0CeBAhFLxMHUrbRGms=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    attrs
    blessed
    humanize
    psutil
    psycopg2
  ];

  pyproject = true;
  pythonImportsCheck = [ "pgactivity" ];

  meta = {
    description = "Top like application for PostgreSQL server activity monitoring";
    homepage = "https://github.com/dalibo/pg_activity";
    license = lib.licenses.postgresql;
    maintainers = with lib.maintainers; [ mausch ];
    mainProgram = "pg_activity";
  };
})
