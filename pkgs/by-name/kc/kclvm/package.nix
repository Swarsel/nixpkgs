{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  protobuf,
  rustPlatform,
  rustc,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kclvm";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "kcl-lang";
    repo = "kcl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6XDLxTpgENhP7F51kicAJB7BNMtX4cONKJApAhqgdno=";
  };

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildInputs = [ rustc ];
  cargoHash = "sha256-kX+3wyeElKXUOIyD24X9jfvSzdtg3HFilkqlWulq4cc=";

  env = {
    PROTOC = "${protobuf}/bin/protoc";
    PROTOC_INCLUDE = "${protobuf}/include";
  };

  preBuild = ''
    cd kclvm
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -id $out/lib/libkclvm_cli_cdylib.dylib $out/lib/libkclvm_cli_cdylib.dylib
  '';

  cargoPatches = [ ./fix-build.patch ];
  cargoRoot = "kclvm";

  meta = {
    description = "High-performance implementation of KCL written in Rust that uses LLVM as the compiler backend";
    homepage = "https://github.com/kcl-lang/kcl";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      selfuryon
    ];

    platforms = lib.platforms.unix;
  };
})
