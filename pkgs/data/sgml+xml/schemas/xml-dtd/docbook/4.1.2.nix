{
  lib,
  stdenv,
  fetchurl,
  findXMLCatalogs,
  unzip,
}:

let
  # Urgh, DocBook 4.1.2 doesn't come with an XML catalog. Use the one
  # from 4.2.
  docbook42catalog = fetchurl {
    hash = "sha256-J0g0JhEzZpuYlm0qU+lKmLc1oUbD5FKQHuUAKrC5kKI=";
    url = "https://www.oasis-open.org/docbook/xml/4.2/catalog.xml";
  };
in

import ./generic.nix {
  inherit
    lib
    stdenv
    fetchurl
    unzip
    findXMLCatalogs
    ;

  version = "4.1.2";

  postInstall = "
    sed 's|V4.2|V4.1.2|g' < ${docbook42catalog} > catalog.xml
  ";

  hash = "sha256-MPBkQGTg6nF1FDglGUCxQx9GrK2oFKBihw9IbHcud3I=";
  url = "https://www.oasis-open.org/docbook/xml/4.1.2/docbkx412.zip";
}
