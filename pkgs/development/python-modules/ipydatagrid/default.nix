{
  lib,
  fetchFromGitHub,
  bqplot,
  buildPythonPackage,
  hatch-jupyter-builder,
  hatchling,
  ipywidgets,
  jupyterlab,
  pandas,
  py2vega,
  pytestCheckHook,
  yarn-berry_3,
}:

let
  yarn-berry = yarn-berry_3;
in

buildPythonPackage rec {
  pname = "ipydatagrid";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "jupyter-widgets";
    repo = "ipydatagrid";
    tag = version;
    hash = "sha256-6jaIYgLbNXIYzM+mZIVMZ1CXOpcbVK5k9nzGjq5UdLI=";
  };

  nativeBuildInputs = [
    yarn-berry.yarnBerryConfigHook
    yarn-berry
  ];

  preConfigure = ''
    substituteInPlace pyproject.toml package.json \
      --replace-fail 'jlpm' 'yarn'
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
    hatch-jupyter-builder
    jupyterlab
  ];

  dependencies = [
    bqplot
    ipywidgets
    pandas
    py2vega
  ];

  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit src;
    hash = "sha256-5KZl9mK6xNvy2XdWieH20hEZJ+h/KzvjOfpo78FlWpg=";
  };

  pyproject = true;

  meta = {
    description = "Fast Datagrid widget for the Jupyter Notebook and JupyterLab";
    homepage = "https://github.com/jupyter-widgets/ipydatagrid";
    changelog = "https://github.com/jupyter-widgets/ipydatagrid/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
