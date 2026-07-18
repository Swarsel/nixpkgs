{
  lib,
  fetchFromGitHub,
  fzf,
  gawk,
  makeWrapper,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "sysz";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "joehillen";
    repo = "sysz";
    rev = version;
    sha256 = "sha256-X9vj6ILPUKFo/i50JNehM2GSDWfxTdroWGYJv765Cm4=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 sysz $out/libexec/sysz
    makeWrapper $out/libexec/sysz $out/bin/sysz \
      --prefix PATH : ${
        lib.makeBinPath [
          fzf
          gawk
        ]
      }
    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Fzf terminal UI for systemctl";
    homepage = "https://github.com/joehillen/sysz";
    changelog = "https://github.com/joehillen/sysz/blob/${version}/CHANGELOG.md";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ hleboulanger ];
    platforms = lib.platforms.unix;
    mainProgram = "sysz";
  };
}
