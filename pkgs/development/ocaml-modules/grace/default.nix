{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  core,
  fmt,
  iter,
  ppx_jane,
  ppx_sexp_conv,
  sexplib,
  uutf,
  dedent ? null,
}:

buildDunePackage (finalAttrs: {
  pname = "grace";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "johnyob";
    repo = "grace";
    tag = finalAttrs.version;
    hash = "sha256-V5K9RGk47K/R+q4wS1FU02kMi1uWSCgdUjKHk7uXuGw=";
  };

  propagatedBuildInputs = [
    fmt
    iter
    uutf
    sexplib
    ppx_sexp_conv
  ];

  doCheck = true;

  checkInputs = [
    core
    ppx_jane
    dedent
  ];

  minimalOCamlVersion = "4.14";

  meta = {
    description = "A fancy diagnostics library that allows your compilers to exit with grace";
    homepage = "https://github.com/johnyob/grace";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ otini ];
  };
})
