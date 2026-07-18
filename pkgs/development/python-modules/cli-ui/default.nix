{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  poetry-core,
  pytestCheckHook,
  tabulate,
  unidecode,
}:
buildPythonPackage rec {
  pname = "cli-ui";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "your-tools";
    repo = "python-cli-ui";
    tag = "v${version}";
    hash = "sha256-BLc55LkVQwZ18V/fD/lBYw6jgchE8n0ijDTSr8/Jkdk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    colorama
    tabulate
    unidecode
  ];

  pyproject = true;
  pythonImportsCheck = [ "cli_ui" ];
  pythonRelaxDeps = [ "tabulate" ];

  meta = {
    description = "Build Nice User Interfaces In The Terminal";
    homepage = "https://github.com/your-tools/python-cli-ui";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ slashformotion ];
  };
}
