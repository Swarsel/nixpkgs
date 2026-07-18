{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "package-version-server";
  version = "0.0.10";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "package-version-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1+7oqWiJd7AZUlaDGYRtR1lyenrlhyaaGeWufW9lPUU=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-AOE0fs3QK8vTIMOIxMg6SooDSQVtqFdB0tF3S88J7Ew=";
  # Needs https://github.com/zed-industries/package-version-server/pull/2 to be merged
  doCheck = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Language server that handles hover information in package.json files";
    homepage = "https://github.com/zed-industries/package-version-server/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ felixdorn ];
    mainProgram = "package-version-server";
  };
})
