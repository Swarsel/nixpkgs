{
  lib,
  clippy,
  nixosTests,
  rustPlatform,
  rustfmt,
}:

let
  cargoToml = fromTOML (builtins.readFile ./Cargo.toml);
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (cargoToml.package) version;
  pname = cargoToml.package.name;

  src = lib.sourceFilesBySuffices ./. [
    ".rs"
    ".toml"
    ".lock"
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postInstall = ''
    for binary in "''${binaries[@]}"; do
      ln -s $out/bin/nixos-init $out/bin/$binary
    done
  '';

  __structuredAttrs = true;

  binaries = [
    "initrd-init"
    "find-etc"
    "clear-etc-opaque"
    "resolve-in-root"
    "env-generator"
  ];

  stripAllList = [ "bin" ];

  passthru.tests = {
    inherit (nixosTests) activation-nixos-init;

    lint-format = finalAttrs.finalPackage.overrideAttrs (
      _: previousAttrs: {
        pname = previousAttrs.pname + "-lint-format";

        nativeCheckInputs = (previousAttrs.nativeCheckInputs or [ ]) ++ [
          clippy
          rustfmt
        ];

        checkPhase = ''
          cargo clippy
          cargo fmt --check
        '';
      }
    );
  };

  meta = {
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nikstur ];
    platforms = lib.platforms.linux;
  };
})
