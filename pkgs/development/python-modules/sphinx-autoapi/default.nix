{
  lib,
  fetchFromGitHub,
  # dependencies
  astroid,
  # tests
  beautifulsoup4,
  buildPythonPackage,
  # build-system
  flit-core,
  jinja2,
  pytestCheckHook,
  pyyaml,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinx-autoapi";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "readthedocs";
    repo = "sphinx-autoapi";
    tag = "v${version}";
    hash = "sha256-pEfyVwvAqIg/1F5kX7WLlhdD+5tq3422u8N6nBizRcA=";
  };

  nativeCheckInputs = [
    beautifulsoup4
    pytestCheckHook
  ];

  build-system = [ flit-core ];

  dependencies = [
    astroid
    jinja2
    pyyaml
    sphinx
  ];

  disabledTests = [
    # require network access
    "test_integration"
  ];

  pyproject = true;
  pythonImportsCheck = [ "autoapi" ];

  meta = {
    description = "Provides 'autodoc' style documentation";

    longDescription = ''
      Sphinx AutoAPI provides 'autodoc' style documentation for
      multiple programming languages without needing to load, run, or
      import the project being documented.
    '';

    homepage = "https://github.com/readthedocs/sphinx-autoapi";
    changelog = "https://github.com/readthedocs/sphinx-autoapi/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
