{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  ipykernel,
  ipython,
  qtconsole,
  qtpy,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "napari-console";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "napari";
    repo = "napari-console";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z1pyG31g+fvTNLbWc2W56zDf33HCx8PvPKwIIc/x2VA=";
  };

  # Circular dependency: napari
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    ipykernel
    ipython
    qtconsole
    qtpy
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "ipykernel"
  ];

  meta = {
    description = "Plugin that adds a console to napari";
    homepage = "https://github.com/napari/napari-console";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ SomeoneSerge ];
  };
})
