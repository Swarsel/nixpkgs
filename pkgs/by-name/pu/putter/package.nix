{
  lib,
  fetchFromSourcehut,
  nix-update-script,
  rustPlatform,
}:

let
  version = "0.1.0";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "putter";

  src = fetchFromSourcehut {
    owner = "~rycee";
    repo = "putter";
    rev = "v${version}";
    hash = "sha256-ZCI8nf7JlTMS+L0+uTBeCIsyx21FjRhP9iT+Kebqgu4=";
  };

  cargoHash = "sha256-36f4f+3vf0ZknmSwe3oNOxPgexTjizXQ73Ac3JeG6ZU=";
  __structuredAttrs = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Symlink or copy files according to a JSON manifest";
    homepage = "https://git.sr.ht/~rycee/putter";
    changelog = "https://git.sr.ht/~rycee/putter/refs/${version}";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ rycee ];
    platforms = lib.platforms.unix;
    mainProgram = "putter";
  };
}
