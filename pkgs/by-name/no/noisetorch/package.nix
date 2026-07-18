{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "NoiseTorch";
  version = "0.12.2";

  src = fetchFromGitHub {
    owner = "noisetorch";
    repo = "NoiseTorch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gOPSMPH99Upi/30OnAdwSb7SaMV0i/uHB051cclfz6A=";
    fetchSubmodules = true;
  };

  vendorHash = null;

  preBuild = ''
    make -C c/ladspa/
    go generate
    rm  ./scripts/*
  '';

  doCheck = false;

  postInstall = ''
    install -D ./assets/icon/noisetorch.png $out/share/icons/hicolor/256x256/apps/noisetorch.png
    install -Dm444 ./assets/noisetorch.desktop $out/share/applications/noisetorch.desktop
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.distribution=nixpkgs"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Virtual microphone device with noise supression for PulseAudio";
    homepage = "https://github.com/noisetorch/NoiseTorch";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      panaeon
    ];

    platforms = lib.platforms.linux;
    mainProgram = "noisetorch";
  };
})
