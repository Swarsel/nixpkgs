{
  lib,
  buildDunePackage,
  charon,

  # nativeBuildInputs,
  menhir,

  # propagatedBuildInputs,
  menhirLib,
  ppx_deriving,
  visitors,
  zarith,
}:

buildDunePackage (finalAttrs: {
  inherit (charon) version;
  inherit (charon) src;
  pname = "name_matcher_parser";
  nativeBuildInputs = [ menhir ];

  propagatedBuildInputs = [
    menhirLib
    ppx_deriving
    visitors
    zarith
  ];

  # No test suite is defined for this package.
  doCheck = false;
  __structuredAttrs = true;

  meta = {
    description = "Parser to define name matchers";
    homepage = "https://github.com/AeneasVerif/charon";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.all;
  };
})
