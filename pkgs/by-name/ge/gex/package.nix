{
  lib,
  stdenv,
  fetchFromCodeberg,
  libgit2,
  nix-update-script,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gex";
  version = "0.6.7";

  src = fetchFromCodeberg {
    owner = "Piturnah";
    repo = "gex";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L8AHJ7h2lNx04nJ//2DjH3CdnuQGMqcta0+XzJjRNb4=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libgit2
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ zlib ];

  cargoHash = "sha256-FdxBYDgDxpZqqYzjX+lWP+uP2jUD3Y5Rzyx+JasAgIY=";

  env = {
    LIBGIT2_NO_VENDOR = 1;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Git Explorer: cross-platform git workflow improvement tool inspired by Magit";
    homepage = "https://codeberg.org/Piturnah/gex";
    changelog = "https://codeberg.org/Piturnah/gex/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      azd325
      bot-wxt1221
      evanrichter
      piturnah
    ];

    mainProgram = "gex";
  };
})
