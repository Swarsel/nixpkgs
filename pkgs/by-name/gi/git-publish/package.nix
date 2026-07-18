{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  perl,
  python3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "git-publish";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "stefanha";
    repo = "git-publish";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jjpbr+ZqG4U8/z0PurnXR+IUKQkG3QB8YqhDkH8uu2Y=";
  };

  nativeBuildInputs = [
    perl
    installShellFiles
  ];

  buildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall

    install -Dm0755 git-publish $out/bin/git-publish
    pod2man git-publish.pod > git-publish.1
    installManPage git-publish.1

    runHook postInstall
  '';

  meta = {
    description = "Prepare and store patch revisions as git tags";
    homepage = "https://github.com/stefanha/git-publish";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "git-publish";
  };
})
