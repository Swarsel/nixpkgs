{
  lib,
  fetchFromGitHub,
  curl,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mdbook-plugins";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "RustForWeb";
    repo = "mdbook-plugins";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Dv2HL8dLV8wOZp+Lhy5qgsZO9sZWOVVIhQZe6JE+F40=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    curl
    openssl
  ];

  cargoHash = "sha256-5vyOxKhTbUFi1kUhm3OlhnEXoSYLdRMIWTTPSVXAvsA=";
  env.OPENSSL_NO_VENDOR = true;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  cargoBuildFlags = [
    "--bin=mdbook-tabs"
    "--bin=mdbook-trunk"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Plugins for mdBook";
    homepage = "https://mdbook-plugins.rustforweb.org/";
    changelog = "https://github.com/RustForWeb/mdbook-plugins/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ redianthus ];
    mainProgram = "mdbook-tabs";
  };
})
