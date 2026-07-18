{
  lib,
  fetchFromGitHub,
  libsodium,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "encrypted-dns-server";
  version = "0.9.21";

  src = fetchFromGitHub {
    owner = "DNSCrypt";
    repo = "encrypted-dns-server";
    tag = finalAttrs.version;
    hash = "sha256-WdKAQISl82ii/C9pILd7HWEE2qtdZpMF32/pRc7lPpk=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libsodium ];
  cargoHash = "sha256-JZRKcvlxciU5MXGLBIXuZeU6tjxKaRaUn3xARN+5JtM=";

  env = {
    SODIUM_USE_PKG_CONFIG = true;
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/encrypted-dns";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Easy to install, high-performance, zero maintenance proxy to run an encrypted DNS server";
    homepage = "https://github.com/DNSCrypt/encrypted-dns-server";
    changelog = "https://github.com/DNSCrypt/encrypted-dns-server/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ paepcke ];
    mainProgram = "encrypted-dns";
  };
})
