{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tidy-viewer";
  version = "1.8.93";

  src = fetchFromGitHub {
    owner = "alexhallam";
    repo = "tv";
    tag = finalAttrs.version;
    sha256 = "sha256-wiVcdTnjEFh5kSyxmK+ab0LkEAbQaygmLdrFfM12DyM=";
  };

  cargoHash = "sha256-HF7M4s2OHCAyVkbCIBxGButAxbxrhjmY3YE/do8et1s=";

  meta = {
    description = "Cross-platform CLI csv pretty printer that uses column styling to maximize viewer enjoyment";
    homepage = "https://github.com/alexhallam/tv";
    changelog = "https://github.com/alexhallam/tv/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ phanirithvij ];
    mainProgram = "tidy-viewer";
  };
})
