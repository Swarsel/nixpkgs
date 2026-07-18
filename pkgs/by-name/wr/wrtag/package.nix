{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "wrtag";
  version = "0.32.0";

  src = fetchFromGitHub {
    owner = "sentriz";
    repo = "wrtag";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j5V3EN6pckR0lVmtkkRoeLIOI5zuW9tSFXFegahsz7w=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-hL8T9mC5re1v17grFXdVF6TidI9P41HKq0hQyG0Yl8c=";

  postInstall = ''
    installShellCompletion contrib/completions/wrtag.{fish,bash}
    installShellCompletion contrib/completions/metadata.fish
  '';

  passthru = {
    tests.version = testers.testVersion {
      command = "wrtag --version";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fast automated music tagging and organization based on MusicBrainz";

    longDescription = ''
      wrtag is a music tagging and organisation tool similar to Beets and MusicBrainz Picard.
      Written in go, it aims to be simpler, more composable and faster.
    '';

    homepage = "https://github.com/sentriz/wrtag";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ quantenzitrone ];
    mainProgram = "wrtag";
  };
})
