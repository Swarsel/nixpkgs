{
  lib,
  fetchFromGitHub,
  bi,
  build-idris-package,
  contrib,
}:
build-idris-package {
  pname = "trees";
  version = "2018-03-19";

  src = fetchFromGitHub {
    owner = "clayrat";
    repo = "idris-trees";
    rev = "dc17f9598bd78ec2b283d91b3c58617960d88c85";
    sha256 = "1c3p69875qc4zdk28im9xz45zw46ajgcmxpqmig63y0z4v3gwxww";
  };

  idrisDeps = [
    contrib
    bi
  ];

  meta = {
    description = "Trees in Idris";
    homepage = "https://github.com/clayrat/idris-trees";
    maintainers = [ lib.maintainers.brainrape ];
  };
}
