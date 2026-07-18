{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "djlint";
  version = "1.36.4";

  src = fetchFromGitHub {
    owner = "djlint";
    repo = "djlint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1DXBDVe8Ae8joJOYwwlBZB8MVubDPVhh+TiJBpL2u2M=";
  };

  build-system = with python3.pkgs; [
    hatchling
  ];

  dependencies = with python3.pkgs; [
    click
    colorama
    cssbeautifier
    jsbeautifier
    json5
    pathspec
    pyyaml
    regex
    tomli
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "djlint" ];

  pythonRelaxDeps = [
    "pathspec"
    "regex"
  ];

  meta = {
    description = "HTML Template Linter and Formatter. Django - Jinja - Nunjucks - Handlebars - GoLang";
    homepage = "https://github.com/djlint/djLint";
    changelog = "https://github.com/djlint/djLint/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ traxys ];
    mainProgram = "djlint";
  };
})
