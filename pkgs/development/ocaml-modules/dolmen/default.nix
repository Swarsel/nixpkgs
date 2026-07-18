{
  lib,
  fetchurl,
  buildDunePackage,
  fmt,
  hmap,
  menhir,
  menhirLib,
  qcheck,
}:

buildDunePackage (finalAttrs: {
  pname = "dolmen";
  version = "0.10";

  src = fetchurl {
    url = "https://github.com/Gbury/dolmen/releases/download/v${finalAttrs.version}/dolmen-${finalAttrs.version}.tbz";
    hash = "sha256-xchfd+OSTzeOjYLxZu7+QTG04EG/nN7KRnQQ8zxx+mE=";
  };

  nativeBuildInputs = [ menhir ];

  propagatedBuildInputs = [
    menhirLib
    fmt
    hmap
  ];

  # Tests fail with menhir ≥ 20260122
  doCheck = false;
  checkInputs = [ qcheck ];

  meta = {
    description = "OCaml library providing clean and flexible parsers for input languages";
    homepage = "https://github.com/Gbury/dolmen";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
