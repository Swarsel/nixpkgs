{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  perl,
  perlPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dnsenum";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "SparrowOchon";
    repo = "dnsenum2";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-I4I+HNQC7xqIF2P7NBy2Ophh3znl5qy9fSicJKIBUis=";
  };

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with perlPackages; [
    perl
    NetDNS
    NetIP
    NetNetmask
    StringRandom
    XMLWriter
    NetWhoisIP
    WWWMechanize
  ];

  installPhase = ''
    install -vD dnsenum.pl $out/bin/dnsenum
    install -vD dns.txt -t $out/share
  '';

  postFixup = ''
    wrapProgram $out/bin/dnsenum \
      --prefix PERL5LIB : "${
        with perlPackages;
        makePerlPath [
          NetIP
          NetDNS
          NetNetmask
          StringRandom
          XMLWriter
          NetWhoisIP
          WWWMechanize
        ]
      }"
  '';

  patchPhase = ''
    rm Makefile
  '';

  meta = {
    description = "Tool to enumerate DNS information";
    homepage = "https://github.com/SparrowOchon/dnsenum2";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ tbutter ];
    platforms = lib.platforms.all;
    mainProgram = "dnsenum";
  };
})
