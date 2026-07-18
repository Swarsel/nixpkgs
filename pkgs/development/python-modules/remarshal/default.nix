{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # propagates
  cbor2,
  colorama,
  # build deps
  poetry-core,
  # tested using
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  rich-argparse,
  ruamel-yaml,
  tomli,
  tomlkit,
  u-msgpack-python,
}:

buildPythonPackage (finalAttrs: {
  pname = "remarshal";
  version = "1.3.0"; # test with `nix-build pkgs/pkgs-lib/format`

  src = fetchFromGitHub {
    owner = "remarshal-project";
    repo = "remarshal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/K8x6ij23pk5O1+XJdFHaGbZ47nFMbXzp+4UMO5dGp4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    cbor2
    colorama
    python-dateutil
    pyyaml
    rich-argparse
    ruamel-yaml
    tomli
    tomlkit
    u-msgpack-python
  ];

  pyproject = true;

  meta = {
    description = "Convert between TOML, YAML and JSON";
    homepage = "https://github.com/remarshal-project/remarshal";
    changelog = "https://github.com/remarshal-project/remarshal/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "remarshal";
  };
})
