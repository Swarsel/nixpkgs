{
  lib,
  capnproto,
  fetchCrate,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "capnproto-rust";
  version = "0.26.0";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-zMaOGwbCnczEY9V2xh3pXuDPYtr91sRblDwSjH/2f0s=";
    crateName = "capnpc";
  };

  cargoHash = "sha256-PgMj+sEvvkkySkL25sgfKzZiKYQX+U0Pt8gJOkZwRzA=";

  nativeCheckInputs = [
    capnproto
  ];

  postInstall = ''
    mkdir -p $out/include/capnp
    cp rust.capnp $out/include/capnp
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cap'n Proto codegen plugin for Rust";
    homepage = "https://github.com/capnproto/capnproto-rust";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mikroskeem
      solson
    ];
  };
})
