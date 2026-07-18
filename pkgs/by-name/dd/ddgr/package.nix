{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ddgr";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "jarun";
    repo = "ddgr";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-88cCQm3eViy0OwSyCTlnW7uuiFwz2/6Wz45QzxCgXxg=";
  };

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ python3 ];
  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    installShellCompletion --bash --name ddgr.bash auto-completion/bash/ddgr-completion.bash
    installShellCompletion --fish auto-completion/fish/ddgr.fish
    installShellCompletion --zsh auto-completion/zsh/_ddgr
  '';

  meta = {
    description = "Search DuckDuckGo from the terminal";
    homepage = "https://github.com/jarun/ddgr";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      ceedubs
      markus1189
    ];

    platforms = python3.meta.platforms;
    mainProgram = "ddgr";
  };
})
