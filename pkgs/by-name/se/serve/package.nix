{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_10,
}:
buildNpmPackage (finalAttrs: {
  pname = "serve";
  version = "14.2.6";

  src = fetchFromGitHub {
    owner = "vercel";
    repo = "serve";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lM04fuzgcLHz8/Jf4wJVYXveFcO6sFyJ9PQAcpweyjk=";
  };

  nativeBuildInputs = [ pnpm_10 ];
  dontNpmBuild = true;
  # takes too long to finish
  dontNpmPrune = true;
  npmConfigHook = pnpmConfigHook;
  npmDeps = null;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-9gejKf+GqB8BPAQtQSuZsTb6jFro3X1aL1noVfyKTPg=";
    pnpm = pnpm_10;
  };

  meta = {
    description = "Static file serving and directory listing";
    homepage = "https://github.com/vercel/serve";
    changelog = "https://github.com/vercel/serve/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "serve";
    downloadPage = "https://github.com/vercel/serve/releases";
  };
})
