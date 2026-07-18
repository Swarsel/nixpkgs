{
  lib,
  fetchFromGitHub,
  libgit2,
  nix-update-script,
  oniguruma,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "git-igitt";
  version = "0.1.21";

  src = fetchFromGitHub {
    owner = "git-bahn";
    repo = "git-igitt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5AVKBew+HShWFZwm4xRmRSL76N2c84Yi97jgcqsslxM=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libgit2
    oniguruma
    zlib
  ];

  cargoHash = "sha256-Z+Y6h9QYszpXFmahU5qXNHvuC4uJ4wJiCd39wndxw5c=";

  env = {
    RUSTONIG_SYSTEM_LIBONIG = true;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Interactive, cross-platform Git terminal application with clear git graphs arranged for your branching model";
    homepage = "https://github.com/git-bahn/git-igitt";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.pinage404 ];
    mainProgram = "git-igitt";
  };
})
