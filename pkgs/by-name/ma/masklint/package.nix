{
  lib,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  rubocop,
  ruff,
  rustPlatform,
  shellcheck,
  withPython ? true,
  withRuby ? true,
  withShell ? true,
}:

let
  version = "0.4.1";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "masklint";

  src = fetchFromGitHub {
    owner = "brumhard";
    repo = "masklint";
    rev = "v${version}";
    hash = "sha256-PhhSJwzLTMFmisrdmsRjxWDBkBr+NjIkENHjdkTeviM=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-WZwl7fdy1HNKQU1zCwifoOvmFRr/fnsvmIG2wf6ILPY=";

  nativeCheckInputs = [
    shellcheck # shells
    ruff # python
    rubocop # ruby
  ];

  postInstall = (
    if (withShell || withPython || withRuby) then
      ''
        wrapProgram $out/bin/masklint \
          --prefix PATH : ${
            lib.makeBinPath (
              (lib.optional withShell shellcheck)
              ++ (lib.optional withPython ruff)
              ++ (lib.optional withRuby rubocop)
            )
          }
      ''
    else
      ""
  );

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lint your mask targets";
    homepage = "https://github.com/brumhard/masklint";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.pinage404 ];
    mainProgram = "masklint";
  };
}
