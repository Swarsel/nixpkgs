{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  celery,
  dash-core-components,
  dash-html-components,
  dash-table,
  diskcache,
  fetchYarnDeps,
  flaky,
  flask,
  flask-compress,
  importlib-metadata,
  kombu,
  mock,
  multiprocess,
  nest-asyncio,
  nodejs,
  numpy,
  plotly,
  psutil,
  pytest-mock,
  pytestCheckHook,
  pyyaml,
  redis,
  requests,
  retrying,
  setuptools,
  typing-extensions,
  werkzeug,
  yarnConfigHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "dash";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "plotly";
    repo = "dash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8LR0iNc8lJBKzbJuvZ8jzta1G3TbQ9yIBSXFvvyeqmI=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    nodejs
  ];

  # as of writing this yarnConfigHook has no parameter that changes in which directory it will be run
  # until then we use preConfigure for entering the directory and preBuild for exiting it
  preConfigure = ''
    pushd @plotly/dash-jupyterlab

    substituteInPlace package.json \
        --replace-fail 'jlpm' 'yarn'
  '';

  preBuild = ''
    # Generate the jupyterlab extension files
    yarn --offline run build:pack

    popd
  '';

  nativeCheckInputs = [
    flaky
    numpy
    psutil
    pytestCheckHook
    pytest-mock
    mock
    pyyaml
    redis
  ];

  build-system = [ setuptools ];

  dependencies = [
    flask
    werkzeug
    plotly
    dash-html-components
    dash-core-components
    dash-table
    importlib-metadata
    typing-extensions
    requests
    retrying
    nest-asyncio
  ];

  disabledTestPaths = [
    "tests/unit/test_browser.py"
    "tests/unit/test_app_runners.py" # Uses selenium
  ];

  enabledTestPaths = [
    "tests/unit"
  ];

  optional-dependencies = {
    celery = [
      celery
      kombu
      redis
    ]
    ++ celery.optional-dependencies.redis;

    compress = [ flask-compress ];

    diskcache = [
      diskcache
      multiprocess
      psutil
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dash" ];

  pythonRelaxDeps = [
    "werkzeug"
    "flask"
  ];

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-Nvm9BS55q/HW9ArpHD01F5Rmx8PLS3yqaz1yDK8Sg68=";
    yarnLock = "${finalAttrs.src}/@plotly/dash-jupyterlab/yarn.lock";
  };

  meta = {
    description = "Python framework for building analytical web applications";
    homepage = "https://dash.plot.ly/";
    changelog = "https://github.com/plotly/dash/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
