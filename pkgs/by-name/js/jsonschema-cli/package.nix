{
  lib,
  cacert,
  fetchCrate,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jsonschema-cli";
  version = "0.47.0";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-0U9NBfkpqCZnNQIxQhNjErX/LehI3xOcUvHiYRKwrXo=";
    pname = "jsonschema-cli";
  };

  cargoHash = "sha256-q/3Nvl+hND94im0mzHqZRepE8GcB5Fec/0HurPgqOmY=";

  preCheck = ''
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast command-line tool for JSON Schema validation";
    homepage = "https://github.com/Stranger6667/jsonschema";
    changelog = "https://github.com/Stranger6667/jsonschema/releases/tag/rust-v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kachick
    ];

    mainProgram = "jsonschema-cli";
  };
})
