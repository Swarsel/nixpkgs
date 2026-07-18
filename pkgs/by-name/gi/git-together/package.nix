{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "git-together";
  version = "0.1.0-alpha.26";

  src = fetchFromGitHub {
    owner = "kejadlen";
    repo = "git-together";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2HgOaqlX0mmmvRlALHm90NAdIhby/jWUJO63bQFqc+4=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-5LKKjHzIlXw0bUmF7GDCVW0cptCxohq6CNPIrMZKorM=";
  env.OPENSSL_NO_VENDOR = true;

  meta = {
    description = "Better commit attribution while pairing without messing with your git workflow";
    homepage = "https://github.com/kejadlen/git-together";
    changelog = "https://github.com/kejadlen/git-together/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sentientmonkey ];
    mainProgram = "git-together";
  };
})
