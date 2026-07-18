{
  lib,
  stdenv,
  autoreconfHook,
  fetchgit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gfshare";
  version = "2.0.0";

  src = fetchgit {
    url = "git://git.gitano.org.uk/libgfshare.git";
    rev = finalAttrs.version;
    sha256 = "0s37xn9pr5p820hd40489xwra7kg3gzqrxhc2j9rnxnd489hl0pr";
  };

  outputs = [
    "bin"
    "lib"
    "dev"
    "out"
  ];

  nativeBuildInputs = [ autoreconfHook ];
  doCheck = true;

  meta = {
    description = "Shamir's secret-sharing method in the Galois Field GF(2**8)";
    # Not the most descriptive homepage but it's what Debian and Ubuntu use
    # https://packages.debian.org/sid/libgfshare2
    # https://launchpad.net/ubuntu/impish/+source/libgfshare/+copyright
    homepage = "https://git.gitano.org.uk/libgfshare.git/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.rraval ];
    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin; # never built on Hydra https://hydra.nixos.org/job/nixpkgs/trunk/gfshare.x86_64-darwin
  };
})
