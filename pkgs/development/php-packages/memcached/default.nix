{
  lib,
  fetchFromGitHub,
  buildPecl,
  cyrus_sasl,
  libmemcached,
  php,
  pkg-config,
  zlib,
}:

buildPecl rec {
  pname = "memcached";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "php-memcached-dev";
    repo = "php-memcached";
    rev = "v${version}";
    sha256 = "sha256-sweEM4TVId+6ySffulmebZpz390dZXb+G3zFZvc45L8=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    cyrus_sasl
    libmemcached
    zlib
  ];

  configureFlags = [
    "--with-zlib-dir=${zlib.dev}"
  ];

  internalDeps = [ php.extensions.session ];

  meta = {
    description = "PHP extension for interfacing with memcached via libmemcached library";
    homepage = "https://github.com/php-memcached-dev/php-memcached";
    license = lib.licenses.php301;
    teams = [ lib.teams.php ];
  };
}
