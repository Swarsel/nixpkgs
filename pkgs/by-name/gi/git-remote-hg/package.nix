{
  lib,
  fetchFromGitHub,
  asciidoc,
  docbook_xml_dtd_45,
  docbook_xsl,
  libxml2,
  libxslt,
  python3Packages,
  xmlto,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "git-remote-hg";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "mnauw";
    repo = "git-remote-hg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QlXi5LQAYMNCF7ZjQdJxwcjp3K51dGkHVnNw0pgArzg=";
  };

  nativeBuildInputs = [
    asciidoc
    xmlto
    docbook_xsl
    docbook_xml_dtd_45
    libxslt
    libxml2
  ];

  postInstall = ''
    make install-doc prefix=$out
  '';

  build-system = with python3Packages; [ setuptools ];
  dependencies = with python3Packages; [ mercurial ];
  pyproject = true;

  meta = {
    description = "Semi-official Mercurial bridge from Git project";
    homepage = "https://github.com/mnauw/git-remote-hg";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
