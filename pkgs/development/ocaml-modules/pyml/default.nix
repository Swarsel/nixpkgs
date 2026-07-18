{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  python3,
  stdcompat,
  utop,
}:

buildDunePackage (finalAttrs: {
  pname = "pyml";
  version = "20250807";

  src = fetchFromGitHub {
    owner = "ocamllibs";
    repo = "pyml";
    tag = finalAttrs.version;
    hash = "sha256-WPtmj9EEs7P72OXWJg1syIrbLuh7u4V4W4nyozXmSa0=";
  };

  strictDeps = true;

  buildInputs = [
    utop
  ];

  propagatedBuildInputs = [
    python3
    stdcompat
  ];

  doCheck = true;

  nativeCheckInputs = [
    python3.pkgs.numpy
    python3.pkgs.ipython
  ];

  __structuredAttrs = true;

  meta = {
    description = "OCaml bindings for Python";
    homepage = "https://github.com/ocamllibs/pyml";
    license = lib.licenses.bsd2;
  };
})
