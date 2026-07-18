{
  lib,
  fetchFromGitHub,
  callPackage,
  nix-update-script,
  nixosTests,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fider";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "getfider";
    repo = "fider";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2aV6f4cgO89hIqksT/kutR+ZRTGncuS04kJ5xZZC5Ds=";
  };

  # Allow easier version overrides, e.g.:
  # pkgs.fider.overrideAttrs (prev: {
  #   version = "...";
  #   src = prev.src.override {
  #     hash = "...";
  #   };
  #   vendorHash = "...";
  #   npmDepsHash = "...";
  # })
  vendorHash = "sha256-4ilOdUblpwteY0ZInitSuzuB8mU1ltYgRJjla6LiziU=";
  npmDepsHash = "sha256-c8CFMMmFcLZkJL50bfLlk2HP9B/rexNZ2WWJkV0x4Rk=";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/etc
    cp -r locale views migrations $out/
    cp -r etc/*.md $out/etc/
    ln -s ${finalAttrs.server}/* $out/
    ln -s ${finalAttrs.frontend}/* $out/

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  frontend = callPackage ./frontend.nix {
    inherit (finalAttrs)
      pname
      version
      src
      npmDepsHash
      ;
  };

  server = callPackage ./server.nix {
    inherit (finalAttrs)
      pname
      version
      src
      vendorHash
      ;
  };

  passthru = {
    tests = {
      inherit (nixosTests) fider;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open platform to collect and prioritize feedback";
    homepage = "https://github.com/getfider/fider";
    changelog = "https://github.com/getfider/fider/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      niklaskorz
    ];

    mainProgram = "fider";
  };
})
