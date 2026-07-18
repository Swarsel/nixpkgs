{
  lib,
  buildPecl,
  php,
}:
buildPecl {
  pname = "igbinary";
  version = "3.2.14";

  outputs = [
    "out"
    "dev"
  ];

  configureFlags = [ "--enable-igbinary" ];
  makeFlags = [ "phpincludedir=$(dev)/include" ];
  sha256 = "sha256-YzcUek+4iAclZmdIN72pko7gbufwEUtDOLhsgWIykl0=";

  meta = {
    description = "Binary serialization for PHP";
    homepage = "https://github.com/igbinary/igbinary/";
    license = lib.licenses.bsd3;
    broken = lib.versionAtLeast php.version "8.5";
    teams = [ lib.teams.php ];
  };
}
