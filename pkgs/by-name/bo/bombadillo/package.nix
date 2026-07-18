{
  lib,
  buildGoModule,
  fetchgit,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "bombadillo";
  version = "2.4.0";

  src = fetchgit {
    url = "https://tildegit.org/sloum/bombadillo.git";
    tag = finalAttrs.version;
    hash = "sha256-FjU9AyRAdGFr1bVpkmj5STkbzCXvpxOaOj7WNQJq7A0=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  postInstall = ''
    installManPage bombadillo.1
  '';

  meta = {
    description = "Non-web client for the terminal, supporting Gopher, Gemini and more";
    homepage = "https://bombadillo.colorfield.space/";
    license = lib.licenses.gpl3;
    mainProgram = "bombadillo";
  };
})
