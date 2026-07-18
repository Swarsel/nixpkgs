{
  lib,
  fetchPypi,
  git,
  mercurial,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "bumpver";
  version = "2026.1132";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "sha256-gLIjwj/Km8ndVpt6RGgJSdNL7iOnOIYNmps28avjsOA=";
  };

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
    git
    mercurial
  ];

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    click
    toml
    lexid
    colorama
  ];

  prePatch = ''
    substituteInPlace setup.py \
      --replace-fail "if any(arg.startswith(\"bdist\") for arg in sys.argv):" ""\
      --replace-fail "import lib3to6" ""\
      --replace-fail "package_dir = lib3to6.fix(package_dir)" ""

    patchShebangs test/fixtures/hooks
  '';

  pyproject = true;

  meta = {
    description = "Bump version numbers in project files";
    homepage = "https://pypi.org/project/bumpver/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kfollesdal ];
    mainProgram = "bumpver";
  };
})
