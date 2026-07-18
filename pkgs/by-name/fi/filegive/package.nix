{
  lib,
  fetchurl,
  buildGoModule,
}:

buildGoModule rec {
  pname = "filegive";
  version = "unstable-2022-05-29";

  src = fetchurl {
    url = "https://viric.name/cgi-bin/filegive/tarball/${rev}/filegive-${rev}.tar.gz";
    hash = "sha256-A69oys59GEysZvQLaYsfoX/X2ENMMH2BGfJqXohQjpc=";
  };

  vendorHash = "sha256-l7FRl58NWGBynMlGu1SCxeVBEzTdxREvUWzmJDiliZM=";

  ldflags = [
    "-s"
    "-w"
  ];

  rev = "5b28e7087a";

  meta = {
    description = "Easy p2p file sending program";
    homepage = "https://viric.name/cgi-bin/filegive";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
    mainProgram = "filegive";
  };
}
