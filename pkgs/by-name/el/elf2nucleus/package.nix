{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  micronucleus,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "elf2nucleus";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "kpcyrd";
    repo = "elf2nucleus";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FAIOtGfGow+0DrPPEBEfvaiinNZLQlGWKJ4DkMj63OA=";
  };

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ micronucleus ];
  cargoHash = "sha256-Xw+heCEwQePyU2gElpG8PTIUZA7y+Onx+2AX2NZzDGs=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd elf2nucleus \
      --bash <($out/bin/elf2nucleus --completions bash) \
      --fish <($out/bin/elf2nucleus --completions fish) \
      --zsh <($out/bin/elf2nucleus --completions zsh)
  '';

  meta = {
    description = "Integrate micronucleus into the cargo buildsystem, flash an AVR firmware from an elf file";
    homepage = "https://github.com/kpcyrd/elf2nucleus";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.marble ];
    mainProgram = "elf2nucleus";
  };
})
