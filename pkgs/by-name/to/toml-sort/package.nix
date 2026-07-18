{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
let
  version = "0.24.4";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "toml-sort";

  src = fetchFromGitHub {
    owner = "pappasam";
    repo = "toml-sort";
    tag = "v${version}";
    hash = "sha256-3xuCnzZ6SKUclvyyWRxHUJy0xF1rnJYwWPZD0OKWFxQ=";
  };

  postPatch = ''
    substituteInPlace "tests/test_cli.py" \
      --replace-fail "toml-sort" "$out/bin/toml-sort"
  '';

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];
  build-system = [ python3Packages.poetry-core ];
  dependencies = [ python3Packages.tomlkit ];
  pyproject = true;

  meta = {
    description = "Command line utility to sort and format your toml files";
    homepage = "https://github.com/pappasam/toml-sort";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ isabelroses ];
    mainProgram = "toml-sort";
  };
}
