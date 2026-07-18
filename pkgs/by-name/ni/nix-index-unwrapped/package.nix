{
  lib,
  fetchFromGitHub,
  curl,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nix-index";
  version = "0.1.10";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nix-index";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IBVI/4hwq84/vZx7Kr/Ci/P/CzPTsn1/oiCIF2vPHXg=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    curl
    sqlite
  ];

  cargoHash = "sha256-9xzC5PE2nyEtbhWGagCX2yZ0/tfo2v3fatnNU+GdVH8=";

  postInstall = ''
    substituteInPlace command-not-found.sh \
      --subst-var out
    install -Dm555 command-not-found.sh -t $out/etc/profile.d
    substituteInPlace command-not-found.nu \
      --subst-var out
    install -Dm555 command-not-found.nu -t $out/etc/profile.d
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  meta = {
    description = "Files database for nixpkgs";
    homepage = "https://github.com/nix-community/nix-index";
    changelog = "https://github.com/nix-community/nix-index/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = with lib.licenses; [ bsd3 ];

    maintainers = with lib.maintainers; [
      bennofs
      ncfavier
    ];

    mainProgram = "nix-index";
  };
})
