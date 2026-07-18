{
  lib,
  fetchFromSourcehut,
  just,
  nix-update-script,
  rustPlatform,
  scdoc,
}:
let
  version = "0.8.0";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "aba";

  src = fetchFromSourcehut {
    owner = "~onemoresuza";
    repo = "aba";
    tag = version;
    hash = "sha256-2zVQNchL4DFh2v2/kwupJTBSmXiKqlxzUMrP9TbfCMs=";
  };

  postPatch = ''
    # Let only nix strip the binary by disabling cargo's `strip = true`, like
    # buildRustPackage does when not using just's setup hooks.
    sed -i '/strip[[:space:]]*=[[:space:]]*true/s/true/false/' ./Cargo.toml
  '';

  nativeBuildInputs = [
    just
    scdoc
  ];

  cargoHash = "sha256-U1f68DY+yV6Uxwk1Re0eSNCFWYrYKCN08hJAYcp4ksE=";

  preBuild = ''
    justFlagsArray+=(
      PREFIX=${placeholder "out"}
      MANIFEST_OPTS="--frozen --locked --profile=release"
      INSTALL_OPTS="--no-track"
    )
  '';

  # There are no tests
  doCheck = false;
  dontUseJustCheck = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Address book for aerc";
    homepage = "https://sr.ht/~onemoresuza/aba/";
    changelog = "https://git.sr.ht/~onemoresuza/aba/tree/main/item/CHANGELOG.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ onemoresuza ];
    mainProgram = "aba";
    downloadPage = "https://git.sr.ht/~onemoresuza/aba/refs/${version}";
  };
}
