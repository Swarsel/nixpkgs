{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  buildEnv,
  fetchpatch,
  gnupg,
  makeWrapper,
  openssl,
  perl,
  perlPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rt";
  version = "5.0.8";

  src = fetchFromGitHub {
    owner = "bestpractical";
    repo = "rt";
    rev = "rt-${finalAttrs.version}";
    hash = "sha256-4/iC1PjLgLAp7XWTafe8HW3bTkDWWQxtSEIOs8wluzE=";
  };

  patches = [
    ./dont-check-users_groups.patch # needed for "make testdeps" to work in the build
    ./override-generated.patch
    # Fix "Wide character in subroutine entry" crash on every request
    # merged upstream
    (fetchpatch {
      hash = "sha256-Mk8ve8n5tgyyHT7RAt2o+QnUlcYNOu95lNjku6VgXS0=";
      url = "https://github.com/bestpractical/rt/commit/f8f03dd6e69dfbf4eb71e3ded0f793af4721a06d.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
  ];

  buildInputs = [
    perl
    (buildEnv {
      name = "rt-perl-deps";

      paths =
        with perlPackages;
        (requiredPerlModules [
          ApacheSession
          BusinessHours
          CGIEmulatePSGI
          CGIPSGI
          CSSMinifierXS
          CSSSquish
          ConvertColor
          CryptEksblowfish
          CryptSSLeay
          CryptX509
          DBDPg
          DBIxSearchBuilder
          DataGUID
          DataICal
          DataPage
          DataPagePageset
          DateExtract
          DateManip
          DateTimeFormatNatural
          DevelGlobalDestruction
          EmailAddress
          EmailAddressList
          EncodeDetect
          EncodeHanExtra
          FCGI
          FCGIProcManager
          FileShareDir
          FileWhich
          GD
          GDGraph
          GnuPGInterface
          GraphViz2
          HTMLFormatExternal
          HTMLFormatTextWithLinks
          HTMLFormatTextWithLinksAndTables
          HTMLGumbo
          HTMLMason
          HTMLMasonPSGIHandler
          HTMLQuoted
          HTMLRewriteAttributes
          HTMLScrubber
          IPCRun
          IPCRun3
          JSON
          JavaScriptMinifierXS
          LWP
          LWPProtocolHttps
          LocaleMaketextFuzzy
          LocaleMaketextLexicon
          LogDispatch
          MIMETools
          MIMETypes
          MailTools
          ModulePath
          ModuleRefresh
          ModuleVersionsReport
          Moose
          MooseXNonMoose
          MooseXRoleParameterized
          MozillaCA
          NetCIDR
          NetIP
          ParallelForkManager
          PathDispatcher
          PerlIOeol
          Plack
          PodParser
          RegexpCommon
          RegexpCommonnetCIDR
          RegexpIPv6
          RoleBasic
          ScopeUpper
          Starlet
          Starman
          StringShellQuote
          SymbolGlobalName
          TermReadKey
          TextPasswordPronounceable
          TextQuoted
          TextTemplate
          TextWikiFormat
          TextWordDiff
          TextWrapper
          TimeParseDate
          TreeSimple
          UNIVERSALrequire
          WebMachine
          XMLRSS
          perlldap
        ]);
    })
  ];

  configureFlags = [
    "--enable-graphviz"
    "--enable-gd"
    "--enable-gpg"
    "--enable-smime"
    "--with-db-type=Pg"
  ];

  preConfigure = ''
    appendToVar configureFlags "--with-web-user=$UID"
    appendToVar configureFlags "--with-web-group=$(id -g)"
    appendToVar configureFlags "--with-rt-group=$(id -g)"
    appendToVar configureFlags "--with-bin-owner=$UID"
    appendToVar configureFlags "--with-libs-owner=$UID"
    appendToVar configureFlags "--with-libs-group=$(id -g)"
  '';

  buildPhase = ''
    make testdeps
  '';

  postFixup = ''
    for i in $(find $out/bin -type f); do
      wrapProgram $i --prefix PERL5LIB ':' $PERL5LIB \
        --prefix PATH ":" "${
          lib.makeBinPath [
            openssl
            gnupg
          ]
        }"
    done

    rm -r $out/var
    mkdir -p $out/var/data
    ln -s /var/log/rt $out/var/log
    ln -s /run/rt/mason_data $out/var/mason_data
    ln -s /var/lib/rt/shredder $out/var/data/RT-Shredder
    ln -s /var/lib/rt/smime $out/var/data/smime
    ln -s /var/lib/rt/gpg $out/var/data/gpg
  '';

  preAutoreconf = ''
    echo rt-${finalAttrs.version} > .tag
  '';

  meta = {
    homepage = "https://github.com/bestpractical/rt";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.unix;
  };
})
