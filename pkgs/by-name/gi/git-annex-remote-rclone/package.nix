{
  lib,
  fetchFromGitHub,
  makeWrapper,
  rclone,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "git-annex-remote-rclone";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "git-annex-remote-rclone";
    repo = "git-annex-remote-rclone";
    rev = "v${version}";
    sha256 = "sha256-B6x67XXE4BHd3x7a8pQlqPPmpy0c62ziDAldB4QpqQ4=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 -t $out/bin git-annex-remote-rclone
    wrapProgram "$out/bin/git-annex-remote-rclone" \
      --prefix PATH ":" "${lib.makeBinPath [ rclone ]}"
  '';

  meta = {
    description = "Use rclone supported cloud storage providers with git-annex";
    homepage = "https://github.com/git-annex-remote-rclone/git-annex-remote-rclone";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.montag451 ];
    platforms = lib.platforms.all;
    mainProgram = "git-annex-remote-rclone";
  };
}
