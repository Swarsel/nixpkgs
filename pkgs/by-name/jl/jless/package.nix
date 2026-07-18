{
  lib,
  stdenv,
  fetchFromGitHub,
  libxcb,
  python3,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jless";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "PaulJuliusMartinez";
    repo = "jless";
    rev = "v${finalAttrs.version}";
    hash = "sha256-76oFPUWROX389U8DeMjle/GkdItu+0eYxZkt1c6l0V4=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ python3 ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ libxcb ];
  cargoHash = "sha256-moXZcPGh0+KyyeUMjH7/+hvF86Penk2o2DQWj4BEzt8=";

  meta = {
    description = "Command-line pager for JSON data";
    homepage = "https://jless.io";
    changelog = "https://github.com/PaulJuliusMartinez/jless/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jfchevrette
    ];

    mainProgram = "jless";
  };
})
