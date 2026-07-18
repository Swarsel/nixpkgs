{
  stdenv,
  fetchFromGitHub,
  boost,
  catch2_3,
  cmake,
  curl,
  git,
  libxml2,
  meta,
  openssl,
  php,
  pname,
  ruby,
  sqlite,
  version,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit
    pname
    version
    meta
    ;

  src = fetchFromGitHub {
    owner = "cfillion";
    repo = "reapack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RhXAjTNAJegeCJaYkvwJedZrXRA92dQ0EeHJr9ngeCg=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    git
    php
    ruby
  ];

  buildInputs = [
    boost
    catch2_3
    curl
    libxml2
    openssl
    sqlite
    zlib
  ];

  cmakeFlags = [ "-Wno-dev" ];

})
