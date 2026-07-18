{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  # TODO: Clean up on `staging`
  lld,
  opus,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "concord-tui";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "chojs23";
    repo = "concord";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/79Hq54qXWXLopPda6xiZ6892UpVoKXQad84QOXCTDM=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ]
  # TODO: Clean up on `staging`
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    lld
  ];

  buildInputs = [
    opus
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
  ];

  cargoHash = "sha256-Ihr4JM0hKEvJ9FMcQ5VPtemJjjPB5mXvAeDa4G0pGSo=";

  # TODO: Clean up on `staging`
  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_CFLAGS_LINK = "-fuse-ld=${lib.getExe' lld "ld64.lld"}";
  };

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  meta = {
    description = "Feature-rich TUI client for Discord, written in Rust";
    homepage = "https://github.com/chojs23/concord";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      Simon-Weij
      neo
      Br1ght0ne
    ];

    mainProgram = "concord";
  };
})
