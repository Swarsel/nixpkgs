{
  lib,
  stdenv,
  fetchFromGitHub,
  bazel_7,
  buildBazelPackage,
  elfutils,
  jdk,
  libcap,
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
buildBazelPackage {
  pname = "perf_data_converter";
  version = "0-unstable-2026-03-10";

  src = fetchFromGitHub {
    owner = "google";
    repo = "perf_data_converter";
    rev = "e2c2da7494e1c6cb8bb343c1bb3023ee3f37ab38";
    hash = "sha256-3YaaEQBlNenJihlEkAI3s4WyjOpWpV9rsfLyvubvfMU=";
  };

  nativeBuildInputs = [ jdk ];

  buildInputs = [
    elfutils
    libcap
  ];

  doCheck = true;
  bazel = bazel_7;
  bazelBuildFlags = [ "-c opt" ];

  bazelFlags = [
    "--registry"
    "file://${registry}"
  ];

  bazelTargets = [ "src:perf_to_profile" ];
  bazelTestTargets = [ "src:all" ];

  buildAttrs = {
    installPhase = ''
      runHook preInstall
      install -Dm555 -t "$out/bin" bazel-bin/src/perf_to_profile
      runHook postInstall
    '';
  };

  fetchAttrs = {
    preInstall = ''
      rm -rf $bazelOut/external/rules_shell~~sh_configure~local_config_shell
    '';

    hash =
      {
        aarch64-linux = "sha256-BlNTjS78QNuoiyIUFDmY5HeqIRJRVZQfrk5Y7+Q2DGo=";
        x86_64-linux = "sha256-jOepM+Lor5RRIQEmdkwf3IJ1AAfbVq2VjMuwqjyfOio=";
      }
      .${system} or (throw "No hash for system: ${system}");
  };

  removeRulesCC = false;

  meta = {
    description = "Tool to convert Linux perf files to the profile.proto format used by pprof";
    homepage = "https://github.com/google/perf_data_converter";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hzeller ];
    platforms = lib.platforms.linux;
  };
}
