{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
}:

buildPythonPackage rec {
  pname = "rocket-errbot";
  version = "1.2.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "181y1wqjvlry5xdzbliajvrxvswzh3myh795jnj1pm92r5grqzda";
  };

  # remove with 1.2.6
  patches = [
    (fetchpatch {
      # https://github.com/errbotio/rocket/pull/1
      name = "errbotio-rocket-pull-1.patch";
      sha256 = "1s668yv5b86b78vbqwhcl44k2l16c9bhk3199yy9hayf0vkxnwif";
      url = "https://github.com/errbotio/rocket/compare/f1a52fe17164f83bccce5e6a1935fc5071c2265f...d69adcd49de5d78bd80f952a2ee31e6a0bac4e3d.patch";
    })
  ];

  format = "setuptools";

  meta = {
    description = "Modern, multi-threaded and extensible web server";
    homepage = "https://github.com/errbotio/rocket";
    license = lib.licenses.mit;
  };
}
