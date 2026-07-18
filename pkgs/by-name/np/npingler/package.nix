{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  installShellFiles,
  nix-update-script,
  rustPlatform,
}:

let
  emulatorAvailable = stdenv.hostPlatform.emulatorAvailable buildPackages;
  emulator = stdenv.hostPlatform.emulator buildPackages;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "npingler";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "9999years";
    repo = "npingler";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C6LJzaT2cfs2EN5Y2TAJv6vujvrNemD5QPyfnISjUvU=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-BkS7W9KCxVrOLpAmI7dC6EWhis0rYfuXcoEmhgQ0WlA=";

  postInstall = lib.optionalString emulatorAvailable ''
    manpages=$(mktemp -d)
    ${emulator} $out/bin/npingler util generate-man-pages "$manpages"
    for manpage in "$manpages"/*; do
      installManPage "$manpage"
    done

    installShellCompletion --cmd npingler \
      --bash <(${emulator} $out/bin/npingler util generate-completions bash) \
      --fish <(${emulator} $out/bin/npingler util generate-completions fish) \
      --zsh  <(${emulator} $out/bin/npingler util generate-completions zsh)
  '';

  buildFeatures = [ "clap_mangen" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Nix profile manager for use with npins";
    homepage = "https://github.com/9999years/npingler";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers._9999years
    ];

    mainProgram = "npingler";
  };
})
