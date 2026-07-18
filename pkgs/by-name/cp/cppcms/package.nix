{
  lib,
  stdenv,
  fetchurl,
  cmake,
  openssl,
  pcre2,
  python3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cppcms";
  version = "2.0.0.beta2";

  src = fetchurl {
    url = "mirror://sourceforge/cppcms/cppcms-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-aXAxx9FB/dIVxr5QkLZuIQamO7PlLwnugSDo78bAiiE=";
  };

  postPatch = ''
    substituteInPlace {,booster/}CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    python3
  ];

  buildInputs = [
    pcre2
    zlib
    openssl
  ];

  cmakeFlags = [
    "--no-warn-unused-cli"
  ];

  meta = {
    description = "High Performance C++ Web Framework";
    homepage = "http://cppcms.com";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.juliendehos ];
    platforms = lib.platforms.linux;
  };
})
