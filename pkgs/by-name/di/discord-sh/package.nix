{
  lib,
  fetchFromGitHub,
  coreutils,
  curl,
  file,
  jq,
  makeWrapper,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "discord-sh";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "fieu";
    repo = "discord.sh";
    rev = "v${version}";
    sha256 = "sha256-z57uMbH6PI68aTMAjA8UIPEefV8sQRR4cS0eK6Ypxuk=";
  };

  # discord.sh looks for the .webhook file in the source code directory, which
  # isn't mutable on Nix
  postPatch = ''
    substituteInPlace discord.sh \
      --replace 'thisdir="$(cd "$(dirname "$(readlink -f "''${BASH_SOURCE[0]}")")" && pwd)"' 'thisdir="$(pwd)"'
  '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm555 discord.sh $out/bin/discord.sh
    wrapProgram $out/bin/discord.sh \
      --set PATH "${
        lib.makeBinPath [
          curl
          jq
          coreutils
          file
        ]
      }"
    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/discord.sh --help

    runHook postInstallCheck
  '';

  # ignore Makefile by disabling buildPhase. Upstream Makefile tries to download
  # binaries from the internet for linting
  dontBuild = true;

  meta = {
    description = "Write-only command-line Discord webhook integration written in 100% Bash script";
    homepage = "https://github.com/fieu/discord.sh";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    platforms = lib.platforms.unix;
    mainProgram = "discord.sh";
  };
}
