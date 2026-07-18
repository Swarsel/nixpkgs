{
  lib,
  fetchFromGitHub,
  build-idris-package,
  hezarfen,
}:
build-idris-package {
  pname = "composition";
  version = "2017-11-12";

  src = fetchFromGitHub {
    owner = "vmchale";
    repo = "composition";
    rev = "8f05e8db750793a9992b315dc0a2c327b837ec8b";
    sha256 = "05424xzxx6f3ig0ravib15nr34nqvaq8spcj6b1512raqrvkkay8";
  };

  idrisDeps = [ hezarfen ];

  meta = {
    description = "Composition extras for Idris";
    homepage = "https://github.com/vmchale/composition";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.brainrape ];
  };
}
