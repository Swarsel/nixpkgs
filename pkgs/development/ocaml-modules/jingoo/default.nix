{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  menhir,
  ounit2,
  ppx_deriving,
  ppxlib,
  re,
  uucp,
  uutf,
}:

buildDunePackage (finalAttrs: {
  pname = "jingoo";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "tategakibunko";
    repo = "jingoo";
    tag = finalAttrs.version;
    hash = "sha256-1357XOYZseItCrIm/qNP46aL8tQyX8CFh77CBycL1ew=";
  };

  nativeBuildInputs = [ menhir ];

  propagatedBuildInputs = [
    ppxlib
    ppx_deriving
    re
    uutf
    uucp
  ];

  doCheck = true;
  checkInputs = [ ounit2 ];

  meta = {
    description = "OCaml template engine almost compatible with jinja2";
    homepage = "https://github.com/tategakibunko/jingoo";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ericbmerritt ];
    mainProgram = "jingoo";
  };
})
