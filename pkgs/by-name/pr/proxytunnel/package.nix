{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  docbook-xsl-nons,
  docbook_xml_dtd_45,
  openssl,
  versionCheckHook,
  xmlto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "proxytunnel";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "proxytunnel";
    repo = "proxytunnel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4+EGVtohM0vL/fXHCXohwWqIBTiIUGbt6AZ7JKpRCT8=";
  };

  nativeBuildInputs = [
    asciidoc
    xmlto
    docbook-xsl-nons
    docbook_xml_dtd_45
  ];

  buildInputs = [ openssl ];
  makeFlags = [ "prefix=${placeholder "out"}" ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Stealth tunneling through HTTP(S) proxies";
    homepage = "http://proxytunnel.sf.net/";
    changelog = "https://github.com/proxytunnel/proxytunnel/raw/${finalAttrs.src.tag}/CHANGES";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      lenianiva
    ];

    platforms = lib.platforms.unix;
    mainProgram = "proxytunnel";
  };
})
