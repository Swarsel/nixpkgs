{
  lib,
  bleach,
  bokeh,
  buildPythonPackage,
  fetchPypi,
  linkify-it-py,
  markdown,
  markdown-it-py,
  mdit-py-plugins,
  narwhals,
  pandas,
  param,
  pyct,
  pyviz-comms,
  requests,
  setuptools,
  tqdm,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "panel";
  version = "1.8.5";

  # We fetch a wheel because while we can fetch the node
  # artifacts using npm, the bundling invoked in setup.py
  # tries to fetch even more artifacts
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-srrwEPz6xMku7/5x9GmQey9/rc/9025C+HxUHLtIw7M=";
    dist = "py3";
    format = "wheel";
    python = "py3";
  };

  propagatedBuildInputs = [
    bleach
    bokeh
    linkify-it-py
    markdown
    markdown-it-py
    mdit-py-plugins
    narwhals
    pandas
    param
    pyct
    pyviz-comms
    requests
    setuptools
    tqdm
    typing-extensions
  ];

  # infinite recursion in test dependencies (hvplot)
  doCheck = false;
  format = "wheel";
  pythonImportsCheck = [ "panel" ];
  pythonRelaxDeps = [ "bokeh" ];

  meta = {
    description = "High level dashboarding library for python visualization libraries";
    homepage = "https://github.com/holoviz/panel";
    changelog = "https://github.com/holoviz/panel/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ locnide ];
    mainProgram = "panel";
  };
}
