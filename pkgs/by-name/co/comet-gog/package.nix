{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  meson,
  ninja,
  pkgsCross,
  rustPlatform,
  comet-gog_kind ? "latest",
}:

let
  versionInfoTable = {
    # version pin that is compatible with heroic
    "heroic" = {
      version = "0.2.0";
      cargoHash = "sha256-SvDE+QqaSK0+4XgB3bdmqOtwxBDTlf7yckTR8XjmMXc=";
      srcHash = "sha256-LAEt2i/SRABrz+y2CTMudrugifLgHNxkMSdC8PXYF0E=";
    };

    "latest" = {
      version = "0.3.2";
      cargoHash = "sha256-AiBoM7rywsuokz/fmLmye630N+t1GtwZsxkmtlH5MI8=";
      srcHash = "sha256-DUkeOkUf9roZGKqdjoy/DfUL1OrVfSVjMhEvfACLEoo=";
    };
  };

  versionInfo = versionInfoTable.${comet-gog_kind};
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (versionInfo) version cargoHash;
  pname = "comet-gog";

  src = fetchFromGitHub {
    owner = "imLinguin";
    repo = "comet";
    tag = "v${finalAttrs.version}";
    hash = versionInfo.srcHash;
    fetchSubmodules = true;
  };

  # error: linker `aarch64-linux-gnu-gcc` not found
  postPatch = ''
    rm .cargo/config.toml
  '';

  # TECHNICALLY, we could remove this, but then we'd be using the vendored precompiled protoc binary...
  env.PROTOC = lib.getExe' buildPackages.protobuf "protoc";

  passthru.dummy-service = stdenv.mkDerivation {
    inherit (finalAttrs) version src;
    pname = "galaxy-dummy-service";

    nativeBuildInputs = [
      meson
      ninja
      pkgsCross.mingwW64.buildPackages.gcc
    ];

    mesonFlags = [
      "--cross-file meson/x86_64-w64-mingw32.ini"
    ];

    installPhase = ''
      runHook preInstall
      install -D GalaxyCommunication.exe -t "$out"/
      runHook postInstall
    '';

    sourceRoot = "${finalAttrs.src.name}/dummy-service";
  };

  meta = {
    description = "Open Source implementation of GOG Galaxy's Communication Service";
    homepage = "https://github.com/imLinguin/comet";
    changelog = "https://github.com/imLinguin/comet/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      tomasajt
    ];

    mainProgram = "comet";
  };
})
