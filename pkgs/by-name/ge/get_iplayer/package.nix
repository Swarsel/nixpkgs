{
  lib,
  stdenv,
  fetchFromGitHub,
  atomicparsley,
  ffmpeg,
  get_iplayer,
  makeWrapper,
  perl,
  perlPackages,
  testers,
}:

perlPackages.buildPerlPackage rec {
  pname = "get_iplayer";
  version = "3.36";

  src = fetchFromGitHub {
    owner = "get-iplayer";
    repo = "get_iplayer";
    rev = "v${version}";
    hash = "sha256-O/mVtbudrYw0jKeSckZlgonFDiWxfeiVc8gdcy4iNBw=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ perl ];

  propagatedBuildInputs = with perlPackages; [
    LWP
    LWPProtocolHttps
    XMLLibXML
    Mojolicious
  ];

  preConfigure = "touch Makefile.PL";
  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -D get_iplayer -t $out/bin
    wrapProgram $out/bin/get_iplayer --suffix PATH : ${
      lib.makeBinPath [
        atomicparsley
        ffmpeg
      ]
    } --prefix PERL5LIB : $PERL5LIB
    install -Dm444 get_iplayer.1 -t $out/share/man/man1

    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion {
    version = "v${version}";
    command = "HOME=$(mktemp -d) get_iplayer --help";
    package = get_iplayer;
  };

  meta = {
    description = "Downloads TV and radio programmes from BBC iPlayer and BBC Sounds";
    homepage = "https://github.com/get-iplayer/get_iplayer";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ rika ];
    platforms = lib.platforms.all;
    mainProgram = "get_iplayer";
  };

}
