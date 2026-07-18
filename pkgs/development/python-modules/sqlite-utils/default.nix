{
  lib,
  buildPythonPackage,
  click,
  click-default-group,
  fetchPypi,
  hypothesis,
  pip,
  pluggy,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  sqlite-fts4,
  sqlite-utils,
  tabulate,
  testers,
}:
buildPythonPackage rec {
  pname = "sqlite-utils";
  version = "3.39";

  src = fetchPypi {
    inherit version;
    hash = "sha256-v6Lqwps+PrXJZHKDeXUn/rz079Spu7Mdl5oUoR75280=";
    pname = "sqlite_utils";
  };

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    click-default-group
    pip
    pluggy
    python-dateutil
    sqlite-fts4
    tabulate
  ];

  pyproject = true;
  pythonImportsCheck = [ "sqlite_utils" ];
  passthru.tests.version = testers.testVersion { package = sqlite-utils; };

  meta = {
    description = "Python CLI utility and library for manipulating SQLite databases";
    homepage = "https://github.com/simonw/sqlite-utils";
    changelog = "https://github.com/simonw/sqlite-utils/releases/tag/${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      meatcar
      techknowlogick
    ];

    mainProgram = "sqlite-utils";
  };
}
