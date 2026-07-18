{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "smug";
  version = "0.3.19";

  src = fetchFromGitHub {
    owner = "ivaaaan";
    repo = "smug";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xJMJgXQcriAgeCVkG/QJqxav1Aiu9XjM/hMPrY4jsHw=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-0PWAY2CeBtaRqkN93ZWeVSynaMW8E9zJwUxI5CzC1mE=";

  postInstall = ''
    installManPage ./man/man1/smug.1
    installShellCompletion completion/smug.{bash,fish}
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "tmux session manager";
    homepage = "https://github.com/ivaaaan/smug";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ juboba ];
    mainProgram = "smug";
  };
})
