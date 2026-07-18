{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  curl,
  darwin,
  docbook_xml_dtd_45,
  docbook_xsl,
  git,
  installShellFiles,
  libiconv,
  makeWrapper,
  perl,
  pkg-config,
  rustPlatform,
  xmlto,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "stgit";
  version = "2.5.5";

  src = fetchFromGitHub {
    owner = "stacked-git";
    repo = "stgit";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zl3xy4t15QwdHeo0cjtorOcmD6oerprUswoMubpVLGU=";
  };

  postPatch = ''
    for f in Documentation/*.xsl; do
      substituteInPlace $f \
        --replace http://docbook.sourceforge.net/release/xsl-ns/current/manpages/docbook.xsl \
                  ${docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl \
        --replace http://docbook.sourceforge.net/release/xsl/current/html/docbook.xsl \
                  ${docbook_xsl}/xml/xsl/docbook/html/docbook.xsl
    done

    substituteInPlace Documentation/texi.xsl \
      --replace http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd \
                ${docbook_xml_dtd_45}/xml/dtd/docbook/docbookx.dtd
  '';

  nativeBuildInputs = [
    pkg-config
    installShellFiles
    makeWrapper
    asciidoc
    xmlto
    docbook_xsl
    docbook_xml_dtd_45
    perl
  ];

  buildInputs = [ curl ];
  cargoHash = "sha256-HPwKKh2QAG690u5pVIIp6Mu6ejaXmIuSuzMLt2tvwhw=";

  makeFlags = [
    "prefix=${placeholder "out"}"
    "XMLTO_EXTRA=--skip-validation"
    "PERL_PATH=${perl}/bin/perl"
  ];

  buildFlags = [ "all" ];

  nativeCheckInputs = [
    git
    perl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.system_cmds
    libiconv
  ];

  postInstall = ''
    wrapProgram $out/bin/stg --prefix PATH : ${lib.makeBinPath [ git ]}

    installShellCompletion --cmd stg \
      --fish completion/stg.fish \
      --bash completion/stgit.bash \
      --zsh completion/stgit.zsh
  '';

  checkTarget = "test";
  dontCargoBuild = true;
  dontCargoCheck = true;
  dontCargoInstall = true;

  installTargets = [
    "install"
    "install-man"
    "install-html"
  ];

  meta = {
    description = "Patch manager implemented on top of Git";
    homepage = "https://stacked-git.github.io/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ jshholland ];
    platforms = lib.platforms.unix;
    mainProgram = "stg";
  };
})
