{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  case-converter,
  jinja2,
  systemrdl-compiler,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "peakrdl-rust";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "darsor";
    repo = "PeakRDL-rust";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1rdTz3w1SEDFWpTjKIk9eLgj3F09lDOMqqdUf8iDd7g=";
  };

  build-system = [ uv-build ];

  dependencies = [
    case-converter
    jinja2
    systemrdl-compiler
  ];

  pyproject = true;

  meta = {
    description = "Generate a Rust crate from SystemRDL for accessing control/status registers";
    homepage = "https://peakrdl-rust.readthedocs.io/";
    license = lib.licenses.lgpl21Only;
    maintainers = [ lib.maintainers.jmbaur ];
  };
})
