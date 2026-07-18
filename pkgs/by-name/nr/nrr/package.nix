{
  lib,
  fetchFromGitHub,
  rustPlatform,
  enableLTO ? true,
  nrxAlias ? true,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nrr";
  version = "0.10.4";

  src = fetchFromGitHub {
    owner = "ryanccn";
    repo = "nrr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/PB5m0gVjhQxYB7IeR59gs4n1vuleFc0ZLBY0a+JYWI=";
  };

  cargoHash = "sha256-QaNn3CrBXbWLquXkIHs4Ba6tbYwwN1XLfysJAnG8Dgc=";

  env = lib.optionalAttrs enableLTO {
    CARGO_PROFILE_RELEASE_CODEGEN_UNITS = "1";
    CARGO_PROFILE_RELEASE_LTO = "fat";
  };

  postInstall = lib.optionalString nrxAlias "ln -s $out/bin/nr{r,x}";

  meta = {
    description = "Minimal, blazing fast npm scripts runner";
    homepage = "https://github.com/ryanccn/nrr";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ryanccn ];
    mainProgram = "nrr";
  };
})
