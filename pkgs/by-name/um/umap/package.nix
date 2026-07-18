{
  lib,
  fetchFromGitHub,
  makeWrapper,
  playwright-driver,
  postgresql,
  postgresqlTestHook,
  python3,
  writeShellScript,
}:
let
  python = python3.override {
    packageOverrides = final: prev: {
      django = prev.django_5.override { withGdal = true; };
    };

    self = python;
  };

in
python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "umap";
  version = "3.7.3";

  src = fetchFromGitHub {
    owner = "umap-project";
    repo = "umap";
    tag = finalAttrs.version;
    hash = "sha256-rM1o83/udkqiVD0nSiAjNVAzriJr2ztvSXh45wxmYzU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  nativeCheckInputs =
    with python.pkgs;
    [
      pytest
      pytest-django
      pytest-playwright
      pytest-xdist
      pytest-rerunfailures
      moto
      factory-boy
      daphne
      pytestCheckHook
    ]
    ++ [
      (postgresql.withPackages (p: [ p.postgis ]))
      postgresqlTestHook
    ];

  preCheck = ''
    export UMAP_SETTINGS=umap/tests/settings.py
    export PLAYWRIGHT_BROWSERS_PATH=${playwright-driver.browsers}
    export DATABASE_URL="" # Defaults to localhost:5432 instead of respecting PGHOST
    export postgresqlTestUserOptions="LOGIN SUPERUSER" # Allow creation of databases
  '';

  postInstall =
    let
      pythonPath = python.pkgs.makePythonPath finalAttrs.passthru.dependencies;
      start_script = writeShellScript "umap-serve" ''
        ${lib.getExe python3.pkgs.uvicorn} "$@" umap.asgi:application;
      '';
    in
    ''
      makeWrapper ${start_script} $out/bin/umap-serve \
        --prefix PYTHONPATH : "$out/${python.sitePackages}" \
        --prefix PYTHONPATH : "${pythonPath}"
    '';

  __structuredAttrs = true;

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies =
    with python.pkgs;
    [
      django
      django-agnocomplete
      django-environ
      django-probes
      django-storages
      pillow
      psycopg
      pydantic
      pydantic-core
      rcssmin
      redis
      requests
      rjsmin
      six
      social-auth-app-django
      social-auth-core
      websockets
      uvicorn
    ]
    ++ django-storages.optional-dependencies.s3;

  disabledTestPaths = [
    # TODO: fix the failing tests
    "umap/tests/integration"
  ];

  disabledTests = [
    # The proxy_request tests require network
    "proxy_request_with"
    "test_good_request_passes"
    "test_valid_proxy_request"
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "django"
    "requests"
    "social-auth-core"
    "social-auth-app-django"
    "psycopg"
    "rcssmin"
    "rjsmin"
    "pillow"
  ];

  passthru = {
    pythonPath = "${finalAttrs.finalPackage}/${python.sitePackages}:${python.pkgs.makePythonPath finalAttrs.passthru.dependencies}";
  };

  meta = {
    description = "UMap lets you create maps with OpenStreetMap layers in a minute and embed them in your site";
    homepage = "https://github.com/umap-project/umap/";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      LorenzBischof
      jcollie
    ];

    mainProgram = "umap";

    teams = with lib.teams; [
      geospatial
      ngi
    ];
  };
})
