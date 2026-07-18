{
  lib,
  fetchFromGitHub,
  binaryen,
  dart-sass,
  ffmpeg,
  nix-update-script,
  nixosTests,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  trunk,
  wasm-bindgen-cli_0_2_105,
  which,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tuliprox";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "euzu";
    repo = "tuliprox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-G+bVKBAxviyJShq2BG4vjMiTzHhoYaiP6FXrSWeTvkU=";
  };

  nativeBuildInputs = [
    pkg-config
    ffmpeg
    which
    wasm-bindgen-cli_0_2_105
    trunk
    rustc.llvmPackages.lld
    binaryen
    dart-sass
  ];

  cargoHash = "sha256-bDQ4pDDTINTgotTen1/SxOZBmkUmbmmwmR4/nSoSf/A=";

  # Needed to get openssl-sys to use pkg-config.
  env = {
    OPENSSL_DIR = "${lib.getDev openssl}";
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
    OPENSSL_NO_VENDOR = 1;
  };

  postBuild = ''
    patchShebangs ./bin/build_resources.sh
    ./bin/build_resources.sh
    pushd frontend
    trunk build --offline --frozen --release
    popd
  '';

  # Tests don't compile in 3.2.0
  doCheck = lib.versionAtLeast finalAttrs.version "3.2.1";

  checkFlags = [
    "--skip=processing::parser::xmltv::tests::normalize"
    "--skip=processing::parser::xtream::tests::test_read_json_file_into_struct"
    "--skip=repository::indexed_document::tests::test_read_xt"
  ];

  postInstall = ''
    cp -rf frontend/dist $out/web
    mkdir -p $out/resources
    cp -rf resources/*.ts $out/resources
  '';

  cargoBuildFlags = "--package tuliprox";

  passthru = {
    tests = { inherit (nixosTests) tuliprox; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Flexible IPTV playlist processor & proxy in Rust";
    homepage = "https://github.com/euzu/tuliprox";
    changelog = "https://github.com/euzu/tuliprox/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ nyanloutre ];
    mainProgram = "tuliprox";
  };
})
