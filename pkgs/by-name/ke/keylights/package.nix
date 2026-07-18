{
  lib,
  stdenv,
  fetchFromCodeberg,
  installShellFiles,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "keylights";
  version = "0.1.0";

  src = fetchFromCodeberg {
    owner = "wjohnsto";
    repo = "keylights";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cl/IRkQMowrWOt0yLEFZC1J2MM6Fr68J6YaakUXwxTQ=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-ns+EppqGP19P+xzevgZcovPKwYkMkWTcu5L0bovuQuk=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    keylightsBin="target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/keylights"

    "$keylightsBin" completions bash > keylights.bash
    "$keylightsBin" completions fish > keylights.fish
    "$keylightsBin" completions zsh > _keylights

    installShellCompletion --cmd keylights \
      --bash keylights.bash \
      --fish keylights.fish \
      --zsh _keylights
  '';

  __structuredAttrs = true;

  passthru.tests.version = testers.testVersion {
    command = "keylights --version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Daemonless CLI for discovering and controlling Elgato Key Light devices";
    homepage = "https://codeberg.org/wjohnsto/keylights";
    changelog = "https://codeberg.org/wjohnsto/keylights/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ wjohnsto ];
    platforms = lib.platforms.linux;
    mainProgram = "keylights";
  };
})
