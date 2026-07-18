{
  lib,
  stdenv,
  fetchFromGitHub,
  bazel_7,
  buildBazelPackage,
  cctools,
  jdk,
  nix-update-script,
}:

let
  system = stdenv.hostPlatform.system;
  registry = fetchFromGitHub {
    hash = "sha256-SLtrNU5uEt8rRJDUdV/IaI37CujsTHLlE31l2zYoRss=";
    owner = "bazelbuild";
    repo = "bazel-central-registry";
    rev = "dc643526b97838ffe421b833dd8b9c95e71702e8";
  };
in
buildBazelPackage rec {
  pname = "bant";
  version = "0.2.10";

  src = fetchFromGitHub {
    owner = "hzeller";
    repo = "bant";
    rev = "v${version}";
    hash = "sha256-jFUPCNVoX4I69ibH+w6c41Gqlu8HosQ3DXQWa3lqUsc=";
  };

  postPatch = ''
    patchShebangs scripts/create-workspace-status.sh
  '';

  strictDeps = true;

  nativeBuildInputs = [
    jdk
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    LIBTOOL = "${cctools}/bin/libtool";
  };

  __structuredAttrs = true;
  bazel = bazel_7;
  bazelBuildFlags = [ "-c opt" ];

  bazelFlags = [
    "--registry"
    "file://${registry}"
  ];

  bazelTargets = [ "//bant:bant" ];
  bazelTestTargets = [ "//..." ];

  buildAttrs = {
    installPhase = ''
      install -D --strip bazel-bin/bant/bant "$out/bin/bant"
    '';
  };

  fetchAttrs = {
    preInstall = ''
      rm -rf $bazelOut/external/rules_shell~~sh_configure~local_config_shell
    '';

    hash =
      {
        aarch64-linux = "sha256-E70F3D7HGsyV0bPd0zbRTytx1UCHyEuNKObaG2eRy8A=";
        x86_64-linux = "sha256-E9XAKrt16DOAne3/wY9PwWIM61YX0fWs8x1hqF3YJSU=";
      }
      .${system} or (throw "No hash for system: ${system}");
  };

  removeRulesCC = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Bazel/Build Analysis and Navigation Tool";
    homepage = "http://bant.build/";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      hzeller
      lromor
    ];
  };
}
