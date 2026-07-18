{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  maturin,
  protobuf_30,
  rustPlatform,
}:
buildPythonPackage (finalAttrs: {
  pname = "pyluwen";
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "luwen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lY7cZ+8C0UEGGYxufl4Vi8g0L4AJFXaGqn7XE2ivTcQ=";
  };

  postPatch = ''
    cd ../$sourceRoot
    cp --no-preserve=ownership,mode ../../Cargo.lock .
    sed -i '0,/version = /{s/version = "*.*.*"/version = "${finalAttrs.version}"/g}' Cargo.toml
  '';

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
    protobuf_30
  ];

  __structuredAttrs = true;
  build-system = [ maturin ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-QBGXbRiBk4WIQFopq1OccmUHgx5GzR/PKhMH4Ie+fyg=";
  };

  prePatch = ''
    chmod -R u+w ../../
    cd ../../
  '';

  pyproject = true;
  sourceRoot = "${finalAttrs.src.name}/bind/pyluwen";

  meta = {
    description = "Tenstorrent system interface library";
    homepage = "https://github.com/tenstorrent/luwen";
    changelog = "https://github.com/tenstorrent/luwen/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ RossComputerGuy ];
  };
})
