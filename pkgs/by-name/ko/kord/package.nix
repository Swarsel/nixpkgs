{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  fetchpatch,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kord";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "twitchax";
    repo = "kord";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-CeMh6yB4fGoxtGLbkQe4OMMvBM0jesyP+8JtU5kCP84=";
  };

  patches = [
    # Fixes build issues due to refactored Rust compiler feature annotations.
    # Should be removable with the next release after v. 0.6.1.
    (fetchpatch {
      excludes = [ "Cargo.*" ];
      hash = "sha256-XQu9P7372J2dHWzvpvbPtALS0Bh8EC+J1EyG3qlak2M=";
      name = "fix-rust-features.patch";
      url = "https://github.com/twitchax/kord/commit/fa9bb979b17d77f54812a915657c3121f76c5d82.patch";
    })
  ];

  # concat_idents feature gate was removed in rust 1.90; never invoked here.
  postPatch = ''
    substituteInPlace src/lib.rs --replace-fail '#![feature(concat_idents)]' ""
  '';

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [ pkg-config ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ rustPlatform.bindgenHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ alsa-lib ];
  cargoHash = "sha256-ciam95rUUh9iKmhTadqWCy1rU4otuRiQkWg0lGRHzng=";
  # kord depends on nightly features
  env.RUSTC_BOOTSTRAP = 1;

  cargoPatches = [
    # bump coreaudio-sys past 0.2.11; bindgen 0.61 panics on apple-sdk-14 anonymous enums
    ./update-coreaudio-sys.patch
  ];

  meta = {
    description = "Music theory binary and library for Rust";
    homepage = "https://github.com/twitchax/kord";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ kidsan ];
  };
})
