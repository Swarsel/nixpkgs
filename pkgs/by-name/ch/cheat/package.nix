{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "cheat";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "cheat";
    repo = "cheat";
    tag = finalAttrs.version;
    sha256 = "sha256-RDfOdyQL9QICXZmgYCmz532iTuPdCW8GixajvEXmaUQ=";
  };

  patches = [
    (builtins.toFile "fix-zsh-completion.patch" ''
      diff --git a/scripts/cheat.zsh b/scripts/cheat.zsh
      index befe1b2..675c9f8 100755
      --- a/scripts/cheat.zsh
      +++ b/scripts/cheat.zsh
      @@ -62,4 +62,4 @@ _cheat() {
         esac
       }

      -compdef _cheat cheat
      +_cheat "$@"
    '')
  ];

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;
  doCheck = false;

  postInstall = ''
    installManPage doc/cheat.1
    installShellCompletion scripts/cheat.{bash,fish,zsh}
  '';

  subPackages = [ "cmd/cheat" ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Create and view interactive cheatsheets on the command-line";

    license = with lib.licenses; [
      gpl3
      mit
    ];

    maintainers = with lib.maintainers; [ mic92 ];
    mainProgram = "cheat";
  };
})
