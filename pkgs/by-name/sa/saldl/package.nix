{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  curl,
  docbook_xml_dtd_45,
  docbook_xsl,
  fetchpatch,
  libevent,
  libxml2,
  libxslt,
  pkg-config,
  python3,
  wafHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "saldl";
  version = "41";

  src = fetchFromGitHub {
    owner = "saldl";
    repo = "saldl";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-PAX2MUyBWWU8kGkaeoCJteidgszh7ipwDJbrLXzVsn0=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-RBMnsUtd0BaZe/EXypDCK4gpUU0dgucWmOcJRn5/iTA=";
      name = "update-waf-to-2-0-24.patch";
      url = "https://github.com/saldl/saldl/commit/360c29d6c8cee5f7e608af42237928be429c3407.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    wafHook
    python3
    asciidoc
    docbook_xml_dtd_45
    docbook_xsl
    libxml2
    libxslt
  ];

  buildInputs = [
    curl
    libevent
  ];

  wafConfigureFlags = [
    "--saldl-version ${finalAttrs.version}"
    "--no-werror"
  ];

  meta = {
    description = "CLI downloader optimized for speed and early preview";
    homepage = "https://saldl.github.io";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ zowoq ];
    platforms = lib.platforms.all;
    mainProgram = "saldl";
  };
})
