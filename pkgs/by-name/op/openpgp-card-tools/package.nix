{
  lib,
  stdenv,
  dbus,
  fetchFromCodeberg,
  installShellFiles,
  openpgp-card-tools,
  pcsclite,
  pkg-config,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "openpgp-card-tools";
  version = "0.11.12";

  src = fetchFromCodeberg {
    owner = "openpgp-card";
    repo = "openpgp-card-tools";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vnyDgFs195QMZtcjBu/fOj5YnqpF1jyCS0KzR1k2HWM=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    pcsclite
    dbus
  ];

  cargoHash = "sha256-T0ehazHODSMpQqVx/6rQS+1cWNaYaojLyiHOYwchuwY=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    OCT_COMPLETION_OUTPUT_DIR=$PWD/shell $out/bin/oct
    installShellCompletion ./shell/oct.{bash,fish} ./shell/_oct
    OCT_MANPAGE_OUTPUT_DIR=$PWD/man $out/bin/oct
    installManPage ./man/*.1
  '';

  passthru = {
    tests.version = testers.testVersion {
      package = openpgp-card-tools;
    };
  };

  meta = {
    description = "Tool for inspecting and configuring OpenPGP cards";
    homepage = "https://codeberg.org/openpgp-card/openpgp-card-tools";

    license = with lib.licenses; [
      asl20 # OR
      mit
    ];

    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "oct";
  };
})
