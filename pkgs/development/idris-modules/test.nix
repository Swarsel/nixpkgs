{
  lib,
  fetchFromGitHub,
  build-idris-package,
  effects,
}:
build-idris-package {
  pname = "test";
  version = "2017-03-30";

  src = fetchFromGitHub {
    owner = "jfdm";
    repo = "idris-testing";
    rev = "604d56f77054931b21975198be669e22427b1f52";
    sha256 = "1pmyhs3jx6wd0pzjd3igfxb9zjs8pqmk4ah352bxjrqdnhqwrl51";
  };

  doCheck = false;
  idrisDeps = [ effects ];

  meta = {
    description = "Testing Utilities for Idris programs";
    homepage = "https://github.com/jfdm/idris-testing";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.brainrape ];
  };
}
