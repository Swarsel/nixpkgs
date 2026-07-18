{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "markdown2html-converter";
  version = "1.1.12";

  src = fetchFromGitHub {
    owner = "magiclen";
    repo = "markdown2html-converter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C35TCmcskhK3sHbkUp3kEaTA4P7Ls5Rn6ahUbzy7KXY=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "Tool for converting a Markdown file to a single HTML file with built-in CSS and JS";
    homepage = "https://github.com/magiclen/markdown2html-converter";
    changelog = "https://github.com/magiclen/markdown2html-converter/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "markdown2html-converter";
  };
})
