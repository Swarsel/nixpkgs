{
  lib,
  atdgen-codec-runtime,
  buildDunePackage,
  cmdliner,
  easy-format,
  menhir,
  nixosTests,
  re,
  yojson,
}:

buildDunePackage {
  inherit (atdgen-codec-runtime) version src;
  pname = "atd";
  nativeBuildInputs = [ menhir ];
  buildInputs = [ cmdliner ];

  propagatedBuildInputs = [
    easy-format
    re
    yojson
  ];

  passthru.tests = {
    smoke-test = nixosTests.atd;
  };

  meta = {
    description = "Syntax for cross-language type definitions";
    homepage = "https://github.com/mjambon/atd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aij ];
    mainProgram = "atdcat";
  };
}
