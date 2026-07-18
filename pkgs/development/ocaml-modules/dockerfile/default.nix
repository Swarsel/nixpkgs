{
  lib,
  fetchFromGitHub,
  alcotest,
  buildDunePackage,
  fmt,
  ppx_sexp_conv,
  sexplib,
}:

buildDunePackage (finalAttrs: {
  pname = "dockerfile";
  version = "8.4.0";

  src = fetchFromGitHub {
    owner = "ocurrent";
    repo = "ocaml-dockerfile";
    tag = finalAttrs.version;
    hash = "sha256-5CHKuVWOVWJ1ZO7r+lrSpHK1mm75Ek1vDR14pDXR9Dk=";
  };

  propagatedBuildInputs = [
    fmt
    ppx_sexp_conv
    sexplib
  ];

  doCheck = true;

  checkInputs = [
    alcotest
  ];

  meta = {
    description = "Interface for creating Dockerfiles";
    homepage = "https://www.ocurrent.org/ocaml-dockerfile/dockerfile/Dockerfile/index.html";
    changelog = "https://github.com/ocurrent/ocaml-dockerfile/blob/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.ethancedwards8 ];
    downloadPage = "https://github.com/ocurrent/ocaml-dockerfile";
  };
})
