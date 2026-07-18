{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  crayons,
  poetry-core,
  pytestCheckHook,
  pyxdg,
  pyyaml,
  requests,
  setuptools,
}:

let
  finalAttrs = {
    pname = "duden";
    version = "0.19.2";

    src = fetchFromGitHub {
      owner = "radomirbosak";
      repo = "duden";
      tag = finalAttrs.version;
      hash = "sha256-wjFIlwd4qG6aG9w0VPus6BGqghwIlPC6a8m0eagvIYM=";
    };

    nativeCheckInputs = [ pytestCheckHook ];
    build-system = [ poetry-core ];

    dependencies = [
      beautifulsoup4
      crayons
      pyxdg
      pyyaml
      requests
      setuptools
    ];

    disabledTestPaths = [
      "tests/test_online_attributes.py"
    ];

    pyproject = true;
    pythonImportsCheck = [ "duden" ];

    meta = {
      description = "CLI for https://duden.de dictionary written in Python";

      longDescription = ''
        duden is a CLI-based program and python module, which can provide
        various information about given german word. The provided data are
        parsed from german dictionary duden.de.
      '';

      homepage = "https://github.com/radomirbosak/duden";
      changelog = "https://github.com/radomirbosak/duden/blob/${finalAttrs.src.rev}/CHANGELOG.md";
      license = with lib.licenses; [ mit ];

      maintainers = with lib.maintainers; [
        linuxissuper
      ];

      mainProgram = "duden";
    };
  };
in
buildPythonPackage finalAttrs
