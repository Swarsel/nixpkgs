{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "deepfilternet";
  version = "0.5.6";

  src = fetchFromGitHub {
    owner = "Rikorose";
    repo = "DeepFilterNet";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5bYbfO1kmduNm9YV5niaaPvRIDRmPt4QOX7eKpK+sWY=";
  };

  cargoHash = "sha256-I0hY2WmaHu/HKQJHyZp0C6wIi0++w5dFeExVMyhInJY=";

  postInstall = ''
    mkdir $out/lib/ladspa
    mv $out/lib/libdeep_filter_ladspa${stdenv.hostPlatform.extensions.sharedLibrary} $out/lib/ladspa/
  '';

  # only the ladspa plugin part has been packaged so far...
  buildAndTestSubdir = "ladspa";

  cargoPatches = [
    # Fix compilation with Rust 1.80 (https://github.com/NixOS/nixpkgs/issues/332957)
    ./cargo-lock-bump-time.patch
  ];

  meta = {
    description = "Noise supression using deep filtering";
    homepage = "https://github.com/Rikorose/DeepFilterNet";
    changelog = "https://github.com/Rikorose/DeepFilterNet/releases/tag/${finalAttrs.src.rev}";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ ralismark ];
  };
})
