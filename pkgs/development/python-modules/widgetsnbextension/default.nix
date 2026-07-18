{
  buildPythonPackage,
  fetchPypi,
  ipywidgets,
  jupyter-packaging,
}:

buildPythonPackage rec {
  pname = "widgetsnbextension";
  version = "4.0.15";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3oYQY5mW8VZ5UtdjpaQa+K838ldaQfmFKjj5R+uCo7k=";
  };

  nativeBuildInputs = [ jupyter-packaging ];
  # No tests in archive
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "widgetsnbextension" ];

  meta = {
    description = "IPython HTML widgets for Jupyter";
    homepage = "https://github.com/jupyter-widgets/ipywidgets/tree/master/python/widgetsnbextension";
    license = ipywidgets.meta.license; # Build from same repo
  };
}
