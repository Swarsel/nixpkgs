{
  docbook-xsl-nons,
  docbook_xml_dtd_45,
  libxml2,
  mkKdeDerivation,
  perl,
  perlPackages,
}:
mkKdeDerivation {
  pname = "kdoctools";

  extraBuildInputs = [
    docbook_xml_dtd_45
    docbook-xsl-nons
  ];

  # Perl could be used both at build time and at runtime.
  extraNativeBuildInputs = [
    perl
    perlPackages.URI
    libxml2
  ];

  extraPropagatedBuildInputs = [
    perl
    perlPackages.URI
  ];
}
