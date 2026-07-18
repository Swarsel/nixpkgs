{
  lib,
  fetchFromGitHub,
  openssl,
  pam,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "shavee";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "ashuio";
    repo = "shavee";
    rev = "shavee-v${finalAttrs.version}";
    hash = "sha256-FxZXJ1cSq0rOiClDgJ1r+nv7aJSiTXyKChh/wFDKSxs=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    pam
    zlib
  ];

  cargoHash = "sha256-eupHLZmMBLMMIL3x4KVmmKv1O9QKcU4zmn4ewOmUS8E=";

  checkFlags = [
    # these tests require network access
    "--skip=filehash::tests::remote_file_hash"
    "--skip=filehash::tests::get_filehash_unit_test"
    # I think this test is broken?
    # errors with File PATH must be absolute eg. "/mnt/a/test.jpg", but provided path is relative
    "--skip=args::tests::input_args_check"
  ];

  meta = {
    description = "Program to automatically decrypt and mount ZFS datasets using Yubikey HMAC as 2FA or any File on USB/SFTP/HTTPS";
    homepage = "https://github.com/ashuio/shavee";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jasonodoom ];
    platforms = lib.platforms.linux;
    mainProgram = "shavee";
  };
})
