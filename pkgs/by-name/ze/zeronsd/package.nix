{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
  rustfmt,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zeronsd";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "zerotier";
    repo = "zeronsd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TL0bgzQgge6j1SpZCdxv/s4pBMSg4/3U5QisjkVE6BE=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-xIuMANJGRHbYBbhlVMXxIVrukW1NY7ucxO79tIdPSpI=";
  env.RUSTFMT = "${rustfmt}/bin/rustfmt";
  # Integration tests try to access the ZeroTier API which requires an API token.
  # https://github.com/zerotier/zeronsd/blob/v0.5.2/tests/service/network.rs#L10
  doCheck = false;

  meta = {
    description = "DNS server for ZeroTier users";
    homepage = "https://github.com/zerotier/zeronsd";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.dstengele ];
  };
})
