{
  lib,
  stdenv,
  fetchFromGitHub,
  bazel_7,
  buildBazelPackage,
  cctools,
  gcc14Stdenv,
}:

let
  # fails to build with gcc15, see https://github.com/NixOS/nixpkgs/issues/475586
  buildBazelPackage' =
    if stdenv.cc.isGNU then
      buildBazelPackage.override {
        stdenv = gcc14Stdenv;
      }
    else
      buildBazelPackage;
in
buildBazelPackage' rec {
  pname = "protoc-gen-js";
  version = "3.21.4";

  src = fetchFromGitHub {
    owner = "protocolbuffers";
    repo = "protobuf-javascript";
    rev = "v${version}";
    hash = "sha256-eIOtVRnHv2oz4xuVc4aL6JmhpvlODQjXHt1eJHsjnLg=";
  };

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    LIBTOOL = "${cctools}/bin/libtool";
  };

  bazel = bazel_7;

  bazelBuildFlags = lib.optionals stdenv.cc.isClang [
    "--cxxopt=-x"
    "--cxxopt=c++"
    "--host_cxxopt=-x"
    "--host_cxxopt=c++"
  ];

  bazelTargets = [ "generator:protoc-gen-js" ];

  buildAttrs.installPhase = ''
    mkdir -p $out/bin
    install -Dm755 bazel-bin/generator/protoc-gen-js $out/bin/
  '';

  fetchAttrs = {
    preInstall = ''
      rm -rv "$bazelOut/external/host_platform"
    '';

    hash = "sha256-znkwUs984vbinz/BLo1uxQ+PvxkpXo719lJu4TD1Vmg=";
  };

  removeLocalConfigCC = false;
  removeRulesCC = false;

  meta = {
    description = "Protobuf plugin for generating JavaScript code";
    homepage = "https://github.com/protocolbuffers/protobuf-javascript";

    license = with lib.licenses; [
      asl20
      bsd3
    ];

    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "protoc-gen-js";
  };
}
