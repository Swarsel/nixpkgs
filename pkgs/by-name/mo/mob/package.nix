{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  espeak-ng,
  makeWrapper,
  withSpeech ? !stdenv.hostPlatform.isDarwin,
}:

buildGoModule (finalAttrs: {
  pname = "mob";
  version = "5.4.2";

  src = fetchFromGitHub {
    owner = "remotemobprogramming";
    repo = "mob";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zb2/uTFlzaR0AFElsYSjwYP2H4p05fDLK02A3awzIFY=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  vendorHash = null;
  doCheck = false;

  preFixup = lib.optionalString withSpeech ''
    wrapProgram $out/bin/mob \
      --set MOB_VOICE_COMMAND "${lib.getBin espeak-ng}/bin/espeak"
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Tool for smooth git handover";
    homepage = "https://github.com/remotemobprogramming/mob";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ericdallo ];
    mainProgram = "mob";
  };
})
