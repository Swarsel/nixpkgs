{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  channels,
  click,
  colorama,
  colorcet,
  contourpy,
  fetchPypi,
  firefox,
  geckodriver,
  isort,
  jinja2,
  json5,
  narwhals,
  nbconvert,
  networkx,
  nodejs,
  numpy,
  packaging,
  pandas,
  pillow,
  psutil,
  pygments,
  pygraphviz,
  pytest,
  pytest-asyncio,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  pyyaml,
  replaceVars,
  requests,
  scipy,
  selenium,
  setuptools,
  toml,
  tornado,
  typing-extensions,
  xyzservices,
}:

buildPythonPackage rec {
  pname = "bokeh";
  # update together with panel which is not straightforward
  version = "3.8.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jn3KzCHVOQVYG1QyitJwWVT3LymX+Z/DMsHejaU6o8w=";
  };

  patches = [
    (replaceVars ./hardcode-nodejs-npmjs-paths.patch {
      node_bin = "${nodejs}/bin/node";
      npm_bin = "${nodejs}/bin/npm";
    })
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', "setuptools-git-versioning"' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  doCheck = false; # need more work

  nativeCheckInputs = [
    pytestCheckHook
    beautifulsoup4
    channels
    click
    colorcet
    firefox
    geckodriver
    isort
    json5
    nbconvert
    networkx
    psutil
    pygments
    pygraphviz
    pytest
    pytest-asyncio
    pytest-xdist
    pytest-timeout
    requests
    scipy
    selenium
    toml
    typing-extensions
  ];

  build-system = [
    colorama
    nodejs
    setuptools
  ];

  dependencies = [
    jinja2
    contourpy
    numpy
    packaging
    pandas
    pillow
    pyyaml
    tornado
    xyzservices
    narwhals
  ];

  pyproject = true;
  pythonImportsCheck = [ "bokeh" ];

  meta = {
    description = "Statistical and novel interactive HTML plots for Python";
    homepage = "https://github.com/bokeh/bokeh";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "bokeh";
  };
}
