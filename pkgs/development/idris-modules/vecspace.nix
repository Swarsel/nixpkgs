{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
}:
build-idris-package {
  pname = "vecspace";
  version = "2018-01-12";

  src = fetchFromGitHub {
    owner = "clayrat";
    repo = "idris-vecspace";
    rev = "6830fa13232f25e9874b3f857b79508b5f82cb99";
    sha256 = "1dwz69cmzblyh7lnyqq2gp0a042z7h02sh5q5wf4xb500vizwkq2";
  };

  idrisDeps = [ contrib ];

  meta = {
    description = "Abstract vector spaces in Idris";
    homepage = "https://github.com/clayrat/idris-vecspace";
    maintainers = [ lib.maintainers.brainrape ];
  };
}
