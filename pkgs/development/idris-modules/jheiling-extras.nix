{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
}:
build-idris-package {
  pname = "extras";
  version = "2018-03-06";

  src = fetchFromGitHub {
    owner = "jheiling";
    repo = "idris-extras";
    rev = "20e79087043ddb00301cdc3036964a2b1c5b1c5f";
    sha256 = "0j34a7vawrkc7nkwwnv6lsjjdcr00d85csjw06nnbh8rj4vj5ps0";
  };

  idrisDeps = [ contrib ];

  meta = {
    description = "Some useful functions for Idris";
    homepage = "https://github.com/jheiling/idris-extras";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.brainrape ];
  };
}
