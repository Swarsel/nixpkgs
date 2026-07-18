{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  jinja2,
  markdown,
  pygments,
  pymdown-extensions,
  pypdf,
  pytest-cov-stub,
  pytestCheckHook,
  python-frontmatter,
  typer,
  watchfiles,
  weasyprint,
}:

buildPythonPackage rec {
  pname = "md2pdf";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "jmaupetit";
    repo = "md2pdf";
    tag = "v${version}";
    hash = "sha256-EZIiuyy2FhHgpCh95/KbYfQpxyPQfDHnB/Q5yo2xVac=";
  };

  nativeCheckInputs = [
    pypdf
    pytest-cov-stub
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export PATH="$out/bin:$PATH"
  '';

  build-system = [ hatchling ];

  dependencies = [
    jinja2
    markdown
    pygments
    pymdown-extensions
    python-frontmatter
    weasyprint
  ];

  disabledTests = [
    # AssertionError caused by
    #     glyph rendered for Unicode string unsupported by fonts: "👋" (U+1F44B)
    "test_generate_pdf_with_jinja_context_input"
    "test_generate_pdf_with_jinja_frontmatter_and_context_input"
    "test_generate_pdf_with_jinja_frontmatter_input"
  ];

  optional-dependencies = {
    cli = [
      typer
      watchfiles
    ];

    latex = [
      # FIXME package markdown-latex
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "md2pdf" ];

  meta = {
    description = "Markdown to PDF conversion tool";
    homepage = "https://github.com/jmaupetit/md2pdf";
    changelog = "https://github.com/jmaupetit/md2pdf/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "md2pdf";
  };
}
