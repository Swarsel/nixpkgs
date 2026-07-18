{
  lib,
  fetchFromGitHub,
  buildGoModule,
  ffmpeg,
  makeBinaryWrapper,
  nix-update-script,
  pulseaudio,
  testers,
}:
let
  self = buildGoModule rec {
    pname = "sblast";
    version = "0.7.2";

    src = fetchFromGitHub {
      owner = "ugjka";
      repo = "sblast";
      rev = "v${version}";
      hash = "sha256-ICSnLfzBoaax3YKa4LiTBQ4zxgDxttxcN4YVLApFH24=";
    };

    nativeBuildInputs = [
      makeBinaryWrapper
    ];

    vendorHash = "sha256-yPwLilMiDR1aSeuk8AEmuYPsHPRWqiByGLwgkdI5t+s=";

    postInstall = ''
      wrapProgram $out/bin/sblast \
          --suffix PATH : ${
            lib.makeBinPath [
              ffmpeg
              pulseaudio
            ]
          }
    '';

    # build only the toplevel package, and not `makerel`
    subPackages = ".";

    passthru = {
      tests.version = testers.testVersion {
        version = "v${version}";
        package = self;
      };

      updateScript = nix-update-script { };
    };

    meta = {
      description = "Blast your Linux audio to DLNA receivers";
      homepage = "https://github.com/ugjka/sblast";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ colinsane ];
      platforms = lib.platforms.linux;
      mainProgram = "sblast";
    };
  };
in
self
