{
  lib,
  stdenv,
  fetchFromCodeberg,
  fetchNpmDeps,
  installShellFiles,
  nodejs,
  npmHooks,
  pkg-config,
  rustPlatform,
  udev,
}:

rustPlatform.buildRustPackage rec {
  pname = "ratman";
  version = "0.7.0";

  src = fetchFromCodeberg {
    owner = "irdest";
    repo = "irdest";
    tag = version;
    hash = "sha256-rdKfKbikyqs0Y/y9A8XRVSKenjHD5rS3blxwy98Tvmg=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [ udev ];
  cargoHash = "sha256-H1XE+khN6sU9WTM87foEQRTK0u5fgDZvoG3//hvd464=";

  cargoBuildFlags = [
    "-p"
    "ratmand"
    "-p"
    "ratman-tools"
  ];

  cargoTestFlags = cargoBuildFlags;

  dashboard = stdenv.mkDerivation rec {
    inherit version src;
    pname = "ratman-dashboard";

    nativeBuildInputs = [
      nodejs
      npmHooks.npmConfigHook
      npmHooks.npmBuildHook
    ];

    installPhase = ''
      mkdir $out
      cp -r dist/* $out/
    '';

    npmBuildScript = "build";

    npmDeps = fetchNpmDeps {
      inherit version;
      pname = "npm-deps-${pname}";
      src = "${src}/ratman/dashboard";
      hash = "sha256-47L4V/Vf8DK3q63MYw3x22+rzIN3UPD0N/REmXh5h3w=";
    };

    sourceRoot = "${src.name}/ratman/dashboard";
  };

  prePatch = ''
    cp -r ${dashboard} ratman/dashboard/dist
  '';

  meta = {
    description = "Modular decentralised peer-to-peer packet router and associated tools";
    homepage = "https://git.irde.st/we/irdest";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ spacekookie ];
    platforms = lib.platforms.unix;
  };
}
