{
  lib,
  fetchFromGitHub,
  coreutils,
  findutils,
  gawk,
  iconv,
  installShellFiles,
  makeWrapper,
  stdenvNoCC,
  wget,
}:
stdenvNoCC.mkDerivation rec {
  pname = "podget";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "dvehrs";
    repo = "podget";
    tag = "V${version}";
    hash = "sha256-0I42UPWTdSzfRJodB1v3BNI5vwt8GRGpHR7eACoR9YQ=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  buildInputs = [
    coreutils
    findutils
    gawk
    iconv
    wget
  ];

  installPhase = ''
    installManPage DOC/podget.7
    install -m 755 -D podget $out/bin/podget
    wrapProgram $out/bin/podget --prefix PATH : ${
      lib.makeBinPath [
        coreutils
        findutils
        gawk
        iconv
        wget
      ]
    }
  '';

  meta = {
    description = "Podcast aggregator optimized for running as a scheduled job (i.e. cron) on Linux";
    homepage = "https://github.com/dvehrs/podget";
    changelog = "https://github.com/dvehrs/podget/blob/dev/Changelog";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ _9R ];
    platforms = lib.platforms.all;
    mainProgram = "podget";
  };
}
