{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  pkg-config,
  protobuf,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "avbroot";
  version = "3.29.0";

  src = fetchFromGitHub {
    owner = "chenxiaolong";
    repo = "avbroot";
    tag = "v${version}";
    hash = "sha256-/c3jYaNGQP4mZA2/MJFWBgaXpTmylgrF3555qdhtr2E=";
  };

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildInputs = [ bzip2 ];
  cargoHash = "sha256-H39Gi2Y3T9PA78ARkJ3i6qHWJSzV/a+TGwXOicEduKQ=";

  meta = {
    description = "Sign (and root) Android A/B OTAs with custom keys while preserving Android Verified Boot";
    homepage = "https://github.com/chenxiaolong/avbroot";
    changelog = "https://github.com/chenxiaolong/avbroot/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ oluceps ];
    mainProgram = "avbroot";
  };
}
