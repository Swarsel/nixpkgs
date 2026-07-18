{
  lib,
  fetchFromGitHub,
  buildPecl,
  php,
  pkg-config,
  zlib,
}:

buildPecl rec {
  pname = "memcache";
  version = "8.2";

  src = fetchFromGitHub {
    owner = "websupport-sk";
    repo = "pecl-memcache";
    rev = version;
    hash = "sha256-77GvQ59XUpIZmdYZP6IhtjdkYwXKuNBSG+LBScz2BtI=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ zlib ];
  configureFlags = [ "--with-zlib-dir=${zlib.dev}" ];
  internalDeps = [ php.extensions.session ];

  meta = {
    description = "PHP extension for interfacing with memcached";
    homepage = "https://github.com/websupport-sk/pecl-memcache";
    license = lib.licenses.php301;
    maintainers = [ lib.maintainers.krzaczek ];
    broken = lib.versionAtLeast php.version "8.5";
    teams = [ lib.teams.php ];
  };
}
