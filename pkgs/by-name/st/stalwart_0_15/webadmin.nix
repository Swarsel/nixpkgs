{
  lib,
  fetchFromGitHub,
  binaryen,
  fetchNpmDeps,
  llvmPackages,
  nix-update-script,
  nodejs,
  npmHooks,
  rustPlatform,
  stalwart_0_15,
  tailwindcss_3,
  trunk,
  wasm-bindgen-cli_0_2_93,
  zip,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "webadmin";
  version = "0.1.37";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "webadmin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-82QvuLkp6j6nJs7jX4NRcnxZ+KNv9RREpM+x8dicfGo=";
  };

  postPatch = ''
    # Using local tailwindcss for compilation
    substituteInPlace Trunk.toml --replace-fail "npx tailwindcss" "tailwindcss"
  '';

  nativeBuildInputs = [
    binaryen
    llvmPackages.bintools-unwrapped
    nodejs
    npmHooks.npmConfigHook
    tailwindcss_3
    trunk
    # needs to match with wasm-bindgen version in upstreams Cargo.lock
    wasm-bindgen-cli_0_2_93

    zip
  ];

  cargoHash = "sha256-qYIg1BthkpS77I6duYGGX168Y/IO8Mx4SWMQbE0BwDA=";
  env.NODE_PATH = "$npmDeps";

  buildPhase = ''
    trunk build --offline --frozen --release
  '';

  installPhase = ''
    cd dist
    mkdir -p $out
    zip -r $out/webadmin.zip *
  '';

  __structuredAttrs = true;

  npmDeps = fetchNpmDeps {
    hash = "sha256-na1HEueX8w7kuDp8LEtJ0nD1Yv39cyk6sEMpS1zix2s=";
    name = "${finalAttrs.pname}-npm-deps";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    inherit (stalwart_0_15.meta) maintainers;
    description = "Web administration module for the Stalwart server";
    homepage = "https://github.com/stalwartlabs/webadmin";
    changelog = "https://github.com/stalwartlabs/webadmin/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
  };
})
