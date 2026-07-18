{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  coreutils,
  getent,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "otel-cli";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "equinix-labs";
    repo = "otel-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JYi9CbP4mUhX0zNjhi6QlBzLKcj2zdPwlyBSIYKp6vk=";
  };

  patches = [ ./patches/bin-echo-patch.patch ];
  vendorHash = "sha256-fWQz7ZrU8gulhpOHSN8Prn4EMC0KXy942FZD/PMsLxc=";

  preCheck = ''
    ln -s $GOPATH/bin/otel-cli .
  ''
  + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    substituteInPlace main_test.go \
      --replace-fail 'const minimumPath = `/bin:/usr/bin`' 'const minimumPath = `${
        lib.makeBinPath [
          getent
          coreutils
        ]
      }`'
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool for sending OpenTelemetry traces";
    homepage = "https://github.com/equinix-labs/otel-cli";
    changelog = "https://github.com/equinix-labs/otel-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "otel-cli";
  };
})
