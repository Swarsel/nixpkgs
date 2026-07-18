let
  # adapted from https://github.com/andrewwutw/build-djgpp/blob/master/script/12.1.0
  gccVersion = "12.2.0";
  binutilsVersion = "230";
  djcrxVersion = "205";
  djlsrVersion = "205";
  djdevVersion = "205";
  gmpVersion = "6.2.1";
  mpfrVersion = "4.1.0";
  mpcVersion = "1.2.1";
  autoconfVersion = "2.69";
  automakeVersion = "1.15.1";
  djgppFtpMirror = "https://www.mirrorservice.org/sites/ftp.delorie.com/pub";
  gnuFtpMirror = "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu";
in
{ fetchurl, fetchFromGitHub }:
{
  inherit gccVersion;

  src = fetchFromGitHub {
    owner = "andrewwutw";
    repo = "build-djgpp";
    rev = "0dc28365825f853c3cc6ad0d8f10f8570bed5828";
    hash = "sha256-L7ROTbnd/Ry/E9cP0N+l0y0cUzkkbC5B2aU9/r3rLQg=";
  };

  autoconf = fetchurl {
    hash = "sha256-ZOvOyfisWySHElqGp3YNJZGsnh09vVlIljP53mKldoQ=";
    url = "${gnuFtpMirror}/autoconf/autoconf-${autoconfVersion}.tar.xz";
  };

  automake = fetchurl {
    hash = "sha256-r2ujkUIiBofFAPebSqLxgdmyTk+NjsSXzqS6JsZL7a8=";
    url = "${gnuFtpMirror}/Automake/automake-${automakeVersion}.tar.xz";
  };

  binutils = fetchurl {
    hash = "sha256-DSFQyFvswmP5/qYXbesFmUJ9tqEFJpILb0mGclfpXX0=";
    url = "${djgppFtpMirror}/djgpp/deleted/v2gnu/bnu${binutilsVersion}s.zip";
  };

  djcrossgcc = fetchurl {
    hash = "sha256-UL+wkeNv3LCQog0JigShIyBM7qJRqvN58Zitmti/BZM=";
    url = "${djgppFtpMirror}/djgpp/rpms/djcross-gcc-${gccVersion}/djcross-gcc-${gccVersion}.tar.bz2";
  };

  djcrx = fetchurl {
    hash = "sha256-IidO2NXuV898zxYfXhaE/RwBkgaHJKfTThveFoBBymA=";
    url = "${djgppFtpMirror}/djgpp/current/v2/djcrx${djcrxVersion}.zip";
  };

  djdev = fetchurl {
    hash = "sha256-RVfftsFh0yZoCuX6cfAJisSUJaGxG5CgILgxYutwXdo=";
    url = "${djgppFtpMirror}/djgpp/current/v2/djdev${djdevVersion}.zip";
  };

  djlsr = fetchurl {
    hash = "sha256-gGkLbkT/i8bGCB/KH0+uuhWRxEkLdu8OyLNYR7ql3uo=";
    url = "${djgppFtpMirror}/djgpp/current/v2/djlsr${djlsrVersion}.zip";
  };

  gcc = fetchurl {
    hash = "sha256-5UnPnPNZSgDie2WJ1DItcOByDN0hPzm+tBgeBpJiMP8=";
    url = "${gnuFtpMirror}/gcc/gcc-${gccVersion}/gcc-${gccVersion}.tar.xz";
  };

  gmp = fetchurl {
    hash = "sha256-/UgpkSzd0S+EGBw0Ucx1K+IkZD6H+sSXtp7d2txJtPI=";
    url = "${gnuFtpMirror}/gmp/gmp-${gmpVersion}.tar.xz";
  };

  mpc = fetchurl {
    hash = "sha256-F1A9LDld/PEGtiLcFCaDwRmUMdCVNnxqrLpu7DA0BFk=";
    url = "${gnuFtpMirror}/mpc/mpc-${mpcVersion}.tar.gz";
  };

  mpfr = fetchurl {
    hash = "sha256-DJij8XMv9spOppBVIHnanFl4ctMOluwoQU7iPJVVin8=";
    url = "${gnuFtpMirror}/mpfr/mpfr-${mpfrVersion}.tar.xz";
  };

}
