{
  lib,
  fetchurl,
  buildDunePackage,
  cairo2,
  camlp-streams,
  dune-configurator,
  gtk3,
  pkg-config,
}:

buildDunePackage (finalAttrs: {
  pname = "lablgtk3";
  version = "3.1.5";

  src = fetchurl {
    url = "https://github.com/garrigue/lablgtk/releases/download/${finalAttrs.version}/lablgtk3-${finalAttrs.version}.tbz";
    hash = "sha256-1IIc2+zzrjdPIDF9Y+Q/5YAww7qWV7UaLoPmUhl+jqw=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dune-configurator
    camlp-streams
  ];

  propagatedBuildInputs = [
    gtk3
    cairo2
  ];

  minimalOCamlVersion = "4.06";

  meta = {
    description = "OCaml interface to GTK 3";
    homepage = "http://lablgtk.forge.ocamlcore.org/";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
