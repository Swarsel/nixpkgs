{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  testers,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "yaml2nix";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "euank";
    repo = "yaml2nix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DkHWWpvBco2yodyOk40LjTNcoaJ1bFKf0JY9OwWgy5M=";
  };

  cargoHash = "sha256-3N0V/5lqiE2lTXu9oUsO3FOXhWqkNlomceqIVDGGuOM=";

  passthru = {
    tests.convert = testers.runCommand {
      nativeBuildInputs = [ finalAttrs.finalPackage ];
      name = "${finalAttrs.pname}-convert-test";

      script = ''
        cat <<EOF > test.yaml
        foo: "bar"
        baz:
          - qux
        EOF

        cat <<EOF > expected.nix
        { foo = "bar"; baz = [ "qux" ]; }
        EOF

        yaml2nix test.yaml > test.nix

        diff test.nix expected.nix && touch $out
      '';
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Command line tool to convert YAML into a Nix expression";
    homepage = "https://github.com/euank/yaml2nix";
    changelog = "https://github.com/euank/yaml2nix/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      gepbird
    ];

    platforms = lib.platforms.unix;
    mainProgram = "yaml2nix";
  };
})
