{
  lib,
  fetchFromGitHub,
  bash,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "cliphist";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "sentriz";
    repo = "cliphist";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y4FSl/Bj80XqCR0ZwjGEkqYUIF6zJHrYyy01XPFlzjU=";
  };

  buildInputs = [ bash ];
  vendorHash = "sha256-4XyDLOJHdre/1BpjgFt/W6gOlPOvKztE+MsbwE3JAaQ=";

  postInstall = ''
    cp ${finalAttrs.src}/contrib/* $out/bin/
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Wayland clipboard manager";
    homepage = "https://github.com/sentriz/cliphist";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "cliphist";
  };
})
