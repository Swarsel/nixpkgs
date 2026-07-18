{
  lib,
  buildPythonPackage,
  fetchPypi,
  ipykernel,
  ipywidgets,
  jinja2,
  jupyter,
  numpy,
  pandas,
  pytestCheckHook,
  setuptools,
  traitlets,
  wheel,
}:

buildPythonPackage rec {
  pname = "pydeck";
  version = "0.9.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wQ2QNegerWOFJkysjRlAJHH2hmoVyh998UAPUhQrz4c=";
  };

  # upstream has an invalid pyproject.toml
  # https://github.com/visgl/deck.gl/issues/8469
  postPatch = ''
    rm pyproject.toml
  '';

  nativeBuildInputs = [
    jinja2
    jupyter
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    jinja2
    numpy
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pandas
  ]
  ++ optional-dependencies.jupyter;

  # tries to start a jupyter server
  disabledTests = [ "test_nbconvert" ];

  optional-dependencies = {
    carto = [
      # pydeck-carto
    ];

    jupyter = [
      ipykernel
      ipywidgets
      traitlets
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pydeck" ];

  meta = {
    description = "Large-scale interactive data visualization in Python";
    homepage = "https://github.com/visgl/deck.gl/tree/master/bindings/pydeck";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ creator54 ];
  };
}
