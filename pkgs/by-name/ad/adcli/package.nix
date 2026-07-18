{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  cyrus_sasl,
  docbook_xml_dtd_43,
  docbook_xsl,
  libkrb5,
  libxslt,
  openldap,
  pkg-config,
  util-linux,
  xmlto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adcli";
  version = "0.9.3a";

  src = fetchFromGitLab {
    owner = "realmd";
    repo = "adcli";
    tag = finalAttrs.version;
    hash = "sha256-IKZ6LW9+aUhNNNp6SL9jllkk7HI/7Ekv7EQo3jQ2VG4=";
    domain = "gitlab.freedesktop.org";
  };

  postPatch = ''
    substituteInPlace tools/Makefile.am \
      --replace-fail 'sbin_PROGRAMS' 'bin_PROGRAMS'

    substituteInPlace doc/Makefile.am \
      --replace-fail 'http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl' \
                     '${docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl'

    function patch_docbook() {
      substituteInPlace $1 \
        --replace-fail "http://www.oasis-open.org/docbook/xml/4.3/docbookx.dtd" \
                       "${docbook_xml_dtd_43}/xml/dtd/docbook/docbookx.dtd"
    }
    patch_docbook doc/adcli.xml
    patch_docbook doc/adcli-devel.xml
    patch_docbook doc/adcli-docs.xml
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    docbook_xsl
    libxslt # xsltproc
    pkg-config
    util-linux
    xmlto
  ];

  buildInputs = [
    cyrus_sasl
    libkrb5
    openldap
  ];

  configureFlags = [
    "--disable-debug"
    "ac_cv_path_KRB5_CONFIG=${lib.getExe' (lib.getDev libkrb5) "krb5-config"}"
  ];

  meta = {
    description = "Helper library and tools for Active Directory client operations";
    homepage = "https://www.freedesktop.org/software/realmd/adcli/adcli.html";
    license = lib.licenses.lgpl21Only;

    maintainers = with lib.maintainers; [
      SohamG
      anthonyroussel
    ];

    platforms = lib.platforms.linux;
    mainProgram = "adcli";
  };
})
