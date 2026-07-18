{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  faketty,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_9,
}:
let
  version = "0.28.0";

  parca-src = fetchFromGitHub {
    hash = "sha256-7ndRiOYa7HiOwwHRXqeCr3A+5EAVvbo4I4vkoqSya+E=";
    owner = "parca-dev";
    repo = "parca";
    tag = "v${version}";
  };

  ui = stdenv.mkDerivation (finalAttrs: {
    inherit version;
    pname = "parca-ui";
    src = "${parca-src}/ui";

    nativeBuildInputs = [
      faketty
      nodejs
      pnpmConfigHook
      pnpm_9
    ];

    # faketty is required to work around a bug in nx.
    # See: https://github.com/nrwl/nx/issues/22445
    buildPhase = ''
      runHook preBuild
      faketty pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/parca
      mv packages/app/web/build $out/share/parca/ui
      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname src version;
      fetcherVersion = 3;
      hash = "sha256-zHdMwJyeafzbIlp+Fhh1khcUVrLsoUg6ViSGm/ByGAA=";
      pnpm = pnpm_9;
    };
  });
in

buildGoModule rec {
  inherit version;
  pname = "parca";
  src = parca-src;
  vendorHash = "sha256-eZPAgxOi1jgTHmisFG/Sz2y3vhxUu/L3Iodb5mrKnVs=";

  preBuild = ''
    # Copy the built UI into the right place for the Go build to embed it.
    cp -r ${ui}/share/parca/ui/* ui/packages/app/web/build
  '';

  ldflags = [
    "-X=main.version=${version}"
    "-X=main.commit=${src.rev}"
  ];

  passthru = {
    inherit ui;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Continuous profiling for analysis of CPU and memory usage";
    homepage = "https://github.com/parca-dev/parca";
    changelog = "https://github.com/parca-dev/parca/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      brancz
      metalmatze
    ];

    platforms = lib.platforms.linux;
    mainProgram = "parca";
  };
}
