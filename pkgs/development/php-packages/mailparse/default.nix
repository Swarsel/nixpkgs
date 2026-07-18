{
  lib,
  buildPecl,
  php,
}:

buildPecl {
  pname = "mailparse";
  version = "3.1.9";

  postConfigure = ''
    echo "#define HAVE_MBSTRING 1" >> config.h
  '';

  hash = "sha256-7LPTydyffOA0GC1Hi3JKw8sCCY78aaOcA1NPCxkgkis=";
  internalDeps = [ php.extensions.mbstring ];

  meta = {
    description = "Mailparse is an extension for parsing and working with email messages";
    homepage = "https://pecl.php.net/package/mailparse";
    license = lib.licenses.php301;
    teams = [ lib.teams.php ];
  };
}
