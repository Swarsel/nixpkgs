{
  lib,
  fetchFromGitHub,
  nixosTests,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "agnos";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "krtab";
    repo = "agnos";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wHzKHduxqG7PBsGK39lCRyzhf47mdjCXhn3W1pOXQO0=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-iRHJ8xmF9CzuVDkBVHD1LGv/YQS5V+oV05+7Pe04ckM=";
  passthru.tests = nixosTests.agnos;

  meta = {
    description = "Obtains certificates from Let's Encrypt using DNS-01 without the need for API access to the DNS provider";
    homepage = "https://github.com/krtab/agnos";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ justinas ];
  };
})
