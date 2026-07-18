{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mdbook-kroki-preprocessor";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "joelcourtney";
    repo = "mdbook-kroki-preprocessor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NTsI/ANqm192sNE9yd2d7ldDLglWoq4L20t84PaAO3M=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-BStTLg44XRdEaQKDNfR+jgjECjZantXTYNk/HX5h7eU=";

  meta = {
    description = "Render Kroki diagrams from files or code blocks in mdbook";
    homepage = "https://github.com/joelcourtney/mdbook-kroki-preprocessor";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];

    mainProgram = "mdbook-kroki-preprocessor";
  };
})
