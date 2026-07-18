{
  # dependencies
  anywidget,
  buildPythonPackage,
  fetchPypi,
  ipykernel,
  jupyter-ui-poll,
  rerun,
}:

buildPythonPackage (finalAttrs: {
  inherit (rerun) version;
  pname = "rerun-notebook";

  # Building this package from source is very cumbersome (it requires a wasm web-viewer
  # cross-compile via cargo + an npm/esbuild bundle). Using the upstream wheel for now.
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-BzmZA37loGsjraNgFPObTARxdlr7lj4w0/hQex7Qeg8=";
    format = "wheel";
    pname = "rerun_notebook";
    python = "py2.py3";
  };

  __structuredAttrs = true;

  dependencies = [
    anywidget
    ipykernel
    jupyter-ui-poll
  ];

  format = "wheel";
  pythonImportsCheck = [ "rerun_notebook" ];

  pythonRelaxDeps = [
    # Upstream pins ipykernel<7.0.0 to dodge ipython/ipykernel#1450.
    "ipykernel"
  ];

  meta = {
    inherit (rerun.meta)
      changelog
      license
      maintainers
      ;

    description = "Implementation helper for running rerun-sdk in notebooks";
    homepage = "https://github.com/rerun-io/rerun/tree/main/rerun_notebook";
  };
})
