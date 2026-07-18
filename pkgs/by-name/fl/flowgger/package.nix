{
  lib,
  capnproto,
  fetchCrate,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "flowgger";
  version = "0.3.2";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-eybahv1A/AIpAXGj6/md8k+b9fu9gSchU16fnAWZP2s=";
  };

  nativeBuildInputs = [
    pkg-config
    capnproto
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-50/rg1Bo8wEpD9UT1EWIKNLglZLS1FigoPtZudDaL4c=";

  checkFlags = [
    # test failed
    "--skip=flowgger::encoder::ltsv_encoder::test_ltsv_full_encode_multiple_sd"
    "--skip=flowgger::encoder::ltsv_encoder::test_ltsv_full_encode_no_sd"
  ];

  meta = {
    description = "Fast, simple and lightweight data collector written in Rust";
    homepage = "https://github.com/awslabs/flowgger";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "flowgger";
  };
})
