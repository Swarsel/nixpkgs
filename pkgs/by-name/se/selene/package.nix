{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
  robloxSupport ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "selene";
  version = "0.31.0";

  src = fetchFromGitHub {
    owner = "kampfkarren";
    repo = "selene";
    tag = finalAttrs.version;
    hash = "sha256-1VxFhr/PxMVQktf1pfhCPEnEi9RF2nTM4p8vYJnPLAk=";
  };

  nativeBuildInputs = lib.optionals robloxSupport [
    pkg-config
  ];

  buildInputs = lib.optionals robloxSupport [
    openssl
  ];

  cargoHash = "sha256-Hv/2F3xBbnYw6GAMUd7nYyZl7pTIuQlgGh6+r3OFglw=";
  buildNoDefaultFeatures = !robloxSupport;

  meta = {
    description = "Blazing-fast modern Lua linter written in Rust";
    homepage = "https://github.com/kampfkarren/selene";
    changelog = "https://github.com/kampfkarren/selene/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ liberodark ];
    mainProgram = "selene";
  };
})
