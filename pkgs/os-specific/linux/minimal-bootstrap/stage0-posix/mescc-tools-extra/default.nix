{
  lib,
  derivationWithMeta,
  kaem-unwrapped,
  m2libcArch,
  m2libcOS,
  mescc-tools,
  platforms,
  src,
  version,
}:
derivationWithMeta {
  inherit
    version
    src
    mescc-tools
    m2libcArch
    m2libcOS
    ;

  pname = "mescc-tools-extra";

  args = [
    "--verbose"
    "--strict"
    "--file"
    ./build.kaem
  ];

  builder = kaem-unwrapped;

  meta = {
    inherit platforms;
    description = "Collection of tools written for use in bootstrapping";
    homepage = "https://github.com/oriansj/mescc-tools-extra";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.minimal-bootstrap ];
  };
}
