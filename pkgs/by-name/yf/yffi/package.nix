{
  lib,
  stdenv,
  fetchFromGitHub,
  rust-cbindgen,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "yffi";
  version = "0.27.3";

  src = fetchFromGitHub {
    owner = "y-crdt";
    repo = "y-crdt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OYqBxhpNw4LAfCLN/xBxSFuwjUV/PZvbg7Kk4AQpvvs=";
  };

  nativeBuildInputs = [
    rust-cbindgen
  ];

  cargoHash = "sha256-eMGhHDcVeySESsgrP5Pj9BwsAgEe8rZHz+0FeFFp7IY=";

  postBuild = ''
    cbindgen --config yffi/cbindgen.toml --crate yffi --output libyrs.h --lang C
  '';

  postCheck = ''
    $CXX -o yrs-ffi-tests -I . tests-ffi/main.cpp target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/libyrs.a
    ./yrs-ffi-tests
  '';

  postInstall = ''
    install -Dm644 libyrs.h $out/include/libyrs.h
  '';

  buildAndTestSubdir = "yffi";

  meta = {
    description = "C foreign function interface for Yrs";
    homepage = "https://github.com/y-crdt/y-crdt/tree/main/yffi";
    changelog = "https://github.com/y-crdt/y-crdt/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = with lib.platforms; linux;
    downloadPage = "https://github.com/y-crdt/y-crdt/tags";
    teams = with lib.teams; [ ngi ];
  };
})
