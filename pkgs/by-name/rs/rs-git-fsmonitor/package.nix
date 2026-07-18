{
  lib,
  fetchFromGitHub,
  makeWrapper,
  rustPlatform,
  watchman,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rs-git-fsmonitor";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "jgavris";
    repo = "rs-git-fsmonitor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+5nR+/09HmFk3mq2B8NTeBT50aBG85yXEdeO6BhStVw=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-WkqJSbtaJxaagJMsdFiVozi1SkrfxXyM9bdZeimwJag=";

  postFixup = ''
    wrapProgram $out/bin/rs-git-fsmonitor --prefix PATH ":" "${lib.makeBinPath [ watchman ]}"
  '';

  meta = {
    description = "Fast git core.fsmonitor hook written in Rust";
    homepage = "https://github.com/jgavris/rs-git-fsmonitor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nilscc ];
    mainProgram = "rs-git-fsmonitor";
  };
})
