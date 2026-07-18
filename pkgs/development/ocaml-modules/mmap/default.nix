{
  lib,
  fetchurl,
  bigarray-compat,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "mmap";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/mirage/mmap/releases/download/v${finalAttrs.version}/mmap-${finalAttrs.version}.tbz";
    hash = "sha256-FgKoq8jiMvqUdxpS5UDleAtAwvJ2Lu5q+9koZQIRbds=";
  };

  propagatedBuildInputs = [ bigarray-compat ];

  meta = {
    description = "Function for mapping files in memory";

    longDescription = ''
      This project provides a Mmap.map_file functions for mapping files in memory.
    '';

    homepage = "https://github.com/mirage/mmap";
    changelog = "https://raw.githubusercontent.com/mirage/mmap/refs/tags/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
