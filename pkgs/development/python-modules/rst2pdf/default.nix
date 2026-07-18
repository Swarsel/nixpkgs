{
  lib,
  buildPythonPackage,
  docutils,
  fetchPypi,
  importlib-metadata,
  installShellFiles,
  jinja2,
  packaging,
  pillow,
  pygments,
  pymupdf,
  pytestCheckHook,
  pyyaml,
  reportlab,
  setuptools,
  setuptools-scm,
  smartypants,
  sphinx,
  wheel,
}:

buildPythonPackage rec {
  pname = "rst2pdf";
  version = "0.105";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-hX6HQQFOxQFfegCq+13Mu1Y3jvTB2lWoKNRLz1/zrNs=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    installShellFiles
    setuptools
    setuptools-scm
    wheel
  ];

  propagatedBuildInputs = [
    docutils
    importlib-metadata
    jinja2
    packaging
    pygments
    pyyaml
    reportlab
    smartypants
    pillow
  ];

  # Test suite fails: https://github.com/rst2pdf/rst2pdf/issues/1067
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pymupdf
    sphinx
  ];

  postInstall = ''
    ${lib.getExe' docutils "rst2man"} doc/rst2pdf.rst rst2pdf.1
    installManPage rst2pdf.1
  '';

  pyproject = true;
  pythonImportsCheck = [ "rst2pdf" ];

  pythonRelaxDeps = [
    "packaging"
    "reportlab"
  ];

  meta = {
    description = "Convert reStructured Text to PDF via ReportLab";
    homepage = "https://rst2pdf.org/";
    changelog = "https://github.com/rst2pdf/rst2pdf/blob/${version}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "rst2pdf";
  };
}
