{
  lib,
  stdenv,
  fetchurl,
  findXMLCatalogs,
  unzip,
  version,
  hash ? "",
  postInstall ? "true",
  src ? fetchurl {
    inherit hash url;
  },
  url ? "https://www.oasis-open.org/docbook/xml/${version}/docbook-xml-${version}.zip",
}:

stdenv.mkDerivation {
  inherit version src postInstall;
  pname = "docbook-xml";
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    find . -type f -exec chmod -x {} \;
    runHook postInstall
  '';

  propagatedNativeBuildInputs = [ findXMLCatalogs ];

  unpackPhase = ''
    mkdir -p $out/xml/dtd/docbook
    cd $out/xml/dtd/docbook
    unpackFile $src
  '';

  meta = {
    platforms = lib.platforms.unix;
    branch = version;
  };
}
