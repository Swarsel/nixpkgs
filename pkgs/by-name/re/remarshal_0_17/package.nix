{
  lib,
  fetchFromGitHub,
  fetchPypi,
  fetchpatch,
  python3Packages,
}:

let
  packageOverrides = self: super: {
    tomlkit = super.tomlkit.overridePythonAttrs (oldAttrs: rec {
      version = "0.12.5";

      src = fetchPypi {
        inherit version;
        hash = "sha256-7vNPujmDTU1rc8m6fz5NHEF6Tlb4mn6W4JDdDSS4+zw=";
        pname = "tomlkit";
      };

      patches = [
        (fetchpatch {
          excludes = [ ".github/workflows/tests.yml" ];
          hash = "sha256-9pLGxcGHs+XoKrqlh7Q0dyc07XrK7J6u2T7Kvfd0ICc=";
          url = "https://github.com/python-poetry/tomlkit/commit/05d9be1c2b2a95a4eb3a53d999f1483dd7abae5a.patch";
        })
      ];
    });
  };
  python = python3Packages.python.override (old: {
    packageOverrides = lib.composeExtensions (old.packageOverrides or (_: _: { })) packageOverrides;
    self = python3Packages.python;
  });
  pythonPackages = python.pkgs;
in
pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "remarshal";
  version = "0.17.1"; # last version with YAML 1.1 support, do not update

  src = fetchFromGitHub {
    owner = "remarshal-project";
    repo = "remarshal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2WxMh5P/8NvElymnMU3JzQU0P4DMXFF6j15OxLaS+VA=";
  };

  nativeCheckInputs = [ pythonPackages.pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ pythonPackages.poetry-core ];

  dependencies = with pythonPackages; [
    cbor2
    colorama
    python-dateutil
    pyyaml
    rich-argparse
    ruamel-yaml
    tomlkit
    u-msgpack-python
  ];

  pyproject = true;
  pythonRemoveDeps = [ "pytest" ];

  # nixpkgs-update: no auto update
  meta = {
    description = "Convert between TOML, YAML and JSON";
    homepage = "https://github.com/remarshal-project/remarshal";
    changelog = "https://github.com/remarshal-project/remarshal/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "remarshal";
  };
})
