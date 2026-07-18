{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxinerama,
  libxrandr,
  libxxf86vm,
  nix-update-script,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "krillinai";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "krillinai";
    repo = "KrillinAI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k1p9v3MQklycW2FsDCyEWNwjLFSymxx1qVg5qhC8xgI=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libxinerama
    libxxf86vm
    libxcursor
    libxrandr
    libx11
    libxi
    libGL
  ];

  vendorHash = "sha256-OdmOalac4oked7vLGMWFCjjNU5TBq1P+HudE5a+bgq4=";
  # open g:\bin\AI\tasks\gdQRrtQP\srt_no_ts_1.srt: no such file or directory
  doCheck = false;

  postInstall = ''
    mv $out/bin/desktop $out/bin/krillinai-desktop
    mv $out/bin/server $out/bin/krillinai-server
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Video translation and dubbing tool";
    homepage = "https://github.com/krillinai/KrillinAI";
    changelog = "https://github.com/krillinai/KrillinAI/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "krillinai-desktop";
  };
})
