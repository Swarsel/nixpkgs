{
  lib,
  stdenv,
  fetchFromGitHub,
  gitMinimal,
  libgit2,
  libiconv,
  makeWrapper,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "keifu";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "trasta298";
    repo = "keifu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ndMWi//G9kwnoPf58YtICyytMv2t0e4h7cwBdfpaoVY=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libgit2
    openssl
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  cargoHash = "sha256-lNctnxVntxRZaS9XeII1sQZ2ZNKkSvd8n+bq5Fwd6QM=";

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  postInstall = ''
    wrapProgram $out/bin/keifu \
      --prefix PATH : ${lib.makeBinPath [ gitMinimal ]}
  '';

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A TUI tool to visualize Git commit graphs with branch genealogy";
    homepage = "https://github.com/trasta298/keifu";
    changelog = "https://github.com/trasta298/keifu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      usu171
    ];

    platforms = lib.platforms.unix;
    mainProgram = "keifu";
  };
})
