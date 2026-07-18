{
  lib,
  stdenv,
  fetchFromGitHub,
  perlPackages,
}:

perlPackages.buildPerlPackage rec {
  pname = "shelldap";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "mahlonsmith";
    repo = "shelldap";
    tag = "v${version}";
    hash = "sha256-67ttAXzu9pfeqjfhMfLMb9vWCXTrE+iUDCbamqswaLg=";
  };

  outputs = [ "out" ];

  buildInputs = with perlPackages; [
    AlgorithmDiff
    AuthenSASL
    IOSocketSSL
    perl
    perlldap
    TermReadLineGnu
    TermShell
    TieIxHash
    YAMLSyck
  ];

  # no make target 'test', not tests provided by source
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm555 -t $out/bin shelldap
    runHook postInstall
  '';

  prePatch = ''
    touch Makefile.PL
  '';

  meta = {
    description = "Handy shell-like interface for browsing LDAP servers and editing their content";
    homepage = "https://github.com/mahlonsmith/shelldap/";
    changelog = "https://github.com/mahlonsmith/shelldap/blob/v${version}/CHANGELOG";
    license = with lib.licenses; [ bsd3 ];

    maintainers = with lib.maintainers; [
      clerie
      tobiasBora
    ];

    platforms = lib.platforms.unix;
    mainProgram = "shelldap";
  };
}
