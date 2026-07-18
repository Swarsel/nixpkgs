{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  jinja2,
  # build-system
  poetry-core,
  pytest,
  rich,
  syrupy,
  textual,
}:

buildPythonPackage rec {
  pname = "pytest-textual-snapshot";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Textualize";
    repo = "pytest-textual-snapshot";
    tag = "v${version}";
    hash = "sha256-ItwwaODnlya/T0Fk5DOPRLoBOwkUN5wq69cELuvy/Js=";
  };

  # The script looks for `resources/snapshot_report_template.jinja2` in the parent folder which
  # is lib/python3.X/site-packages
  # Let's avoid to have a random 'resources' folder in the PYTHONPATH.
  # Instead, we move this `resources` folder in `$out/share` (see postInstall below) and patch the
  # path in the script.
  postPatch = ''
    substituteInPlace pytest_textual_snapshot.py \
      --replace-fail \
        "this_file_path.parent" \
        "Path('$out/share/pytest-textual-snapshot/')"
  '';

  # Module has no tests
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/pytest-textual-snapshot/
    cp -r resources $out/share/pytest-textual-snapshot/
  '';

  build-system = [ poetry-core ];

  dependencies = [
    jinja2
    pytest
    rich
    syrupy
    textual
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_textual_snapshot" ];

  pythonRelaxDeps = [
    "syrupy"
  ];

  meta = {
    description = "Snapshot testing for Textual applications";
    homepage = "https://github.com/Textualize/pytest-textual-snapshot";
    changelog = "https://github.com/Textualize/pytest-textual-snapshot/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
