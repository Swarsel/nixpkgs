{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # dependencies
  pyyaml,
  ruamel-yaml,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "hyperpyyaml";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "speechbrain";
    repo = "hyperpyyaml";
    tag = "v${version}";
    hash = "sha256-/7OrIR61zQYl2+RjiOOlaqUGWBieon5fe8sgmEvKowo=";
  };

  postPatch = ''
    # https://github.com/speechbrain/HyperPyYAML/pull/33
    substituteInPlace hyperpyyaml/core.py \
      --replace-fail \
        "    hparams = yaml.load(yaml_stream, Loader=loader)" \
        "    if not hasattr(loader, 'max_depth'):
            loader.max_depth = 0
        hparams = yaml.load(yaml_stream, Loader=loader)"
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    pyyaml
    ruamel-yaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "hyperpyyaml" ];
  # https://github.com/speechbrain/HyperPyYAML/pull/33
  pythonRelaxDeps = [ "ruamel.yaml" ];

  meta = {
    description = "Extensions to YAML syntax for better python interaction";
    homepage = "https://github.com/speechbrain/HyperPyYAML";
    changelog = "https://github.com/speechbrain/HyperPyYAML/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
