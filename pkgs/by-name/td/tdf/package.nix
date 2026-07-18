{
  lib,
  fetchFromGitHub,
  cairo,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tdf";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "itsjunetime";
    repo = "tdf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YjIMuwQkPtwlGiQ2zs3lEZi28lfn9Z5b5zOYIDFf5qw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    rustPlatform.bindgenHook
    cairo
  ];

  cargoHash = "sha256-lGbsb3hlFen0tXBVLbm8+CE5dddv6Ner4YSAvAd3/ug=";
  # Tests depend on cpuprofiler, which is not packaged in nixpkgs
  doCheck = false;

  # Only used for development
  postInstall = ''
    rm "$out/bin/for_profiling"
  '';

  buildFeatures = [
    "epub"
    "cbz"
  ];

  meta = {
    description = "Tui-based PDF viewer";
    homepage = "https://github.com/itsjunetime/tdf";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      luftmensch-luftmensch
      DieracDelta
    ];

    platforms = lib.platforms.unix;
    mainProgram = "tdf";
  };
})
