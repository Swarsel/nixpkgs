{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oxipng";
  version = "10.1.1";

  # do not use fetchCrate (only repository includes tests)
  src = fetchFromGitHub {
    owner = "shssoichiro";
    repo = "oxipng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-G06GAlxEVOqt2xHq+JOLSYbsa++aArbu+sb0ypQn9u4=";
  };

  # don't require qemu for aarch64-linux tests
  # error: linker `aarch64-linux-gnu-gcc` not found
  postPatch = ''
    rm .cargo/config.toml
  '';

  cargoHash = "sha256-gRWDpxZGy01lWgCIse4Tf7gjwxzosozONB3LD5pX5KQ=";

  meta = {
    description = "Multithreaded lossless PNG compression optimizer";
    homepage = "https://github.com/shssoichiro/oxipng";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dywedir ];
    mainProgram = "oxipng";
  };
})
