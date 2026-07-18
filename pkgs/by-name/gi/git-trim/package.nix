{
  lib,
  fetchFromGitHub,
  fetchpatch,
  libgit2,
  openssl,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "git-trim";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "foriequal0";
    repo = "git-trim";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-XAO3Qg5I2lYZVNx4+Z5jKHRIFdNwBJsUQwJXFb4CbvM=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    libgit2
    zlib
  ];

  cargoHash = "sha256-irgekVTWCujzSbZQMNJw3NZ3cjaUftpSJha6iZQqYJ8=";
  env.OPENSSL_NO_VENDOR = 1;
  # fails with sandbox
  doCheck = false;

  postInstall = ''
    install -Dm644 -t $out/share/man/man1/ docs/git-trim.1
  '';

  cargoPatches = [
    # Update git2 https://github.com/foriequal0/git-trim/pull/202
    (fetchpatch {
      sha256 = "sha256-C1pX4oe9ZCgvqYTBJeSjMdr0KFyjv2PNVMJDlwCAngY=";
      url = "https://github.com/foriequal0/git-trim/commit/4355cd1d6f605455087c4d7ad16bfb92ffee941f.patch";
    })
  ];

  meta = {
    description = "Automatically trims your branches whose tracking remote refs are merged or gone";
    homepage = "https://github.com/foriequal0/git-trim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cafkafk ];
    mainProgram = "git-trim";
  };
})
