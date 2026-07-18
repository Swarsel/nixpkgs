{
  lib,
  fetchFromGitHub,
  boringssl,
  cacert,
  nix-update-script,
  python3,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "trusttunnel-endpoint";
  version = "1.0.41";

  src = fetchFromGitHub {
    owner = "TrustTunnel";
    repo = "TrustTunnel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZFlHX17n0GQ+HVbJD9NQ5Jeg93G9A7dkjSkRD84ZNFQ=";
  };

  postPatch = ''
    substituteInPlace $cargoDepsCopy/*/boring-sys-*/build/main.rs $cargoDepsCopy/*/quiche-*/src/build.rs \
      --replace-fail "cargo:rustc-link-lib=static=crypto" "cargo:rustc-link-lib=dylib=crypto" \
      --replace-fail "cargo:rustc-link-lib=static=ssl" "cargo:rustc-link-lib=dylib=ssl"
  '';

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    boringssl
  ];

  cargoHash = "sha256-2ivFP6JjFFlScO6jcaHOTzcmntKlmOmJQE0q/81NOxc=";

  env = {
    BORING_BSSL_INCLUDE_PATH = "${boringssl.dev}/include";
    BORING_BSSL_PATH = boringssl;
  };

  nativeCheckInputs = [
    cacert
    python3
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern, fast and obfuscated VPN protocol - endpoint component";
    homepage = "https://github.com/TrustTunnel/TrustTunnel";
    changelog = "https://github.com/TrustTunnel/TrustTunnel/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ k900 ];
    mainProgram = "trusttunnel_endpoint";
  };
})
