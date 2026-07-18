{
  lib,
  stdenv,
  fetchFromGitHub,
  bazel_8,
  callPackage,
  cctools,
  jdk_headless,
  libgcc,
  zlib,
}:
let
  bazelPackage = callPackage ./build-support/bazelPackage.nix { };
  registry = fetchFromGitHub {
    owner = "bazelbuild";
    repo = "bazel-central-registry";
    rev = "722299976c97e5191045c8016b7c8532189fc3f6";
    sha256 = "sha256-hi5BKI94am2LCXD93GBeT0gsODxGeSsd0OrhTwpNAgM=";
  };
  src = fetchFromGitHub {
    owner = "bazelbuild";
    repo = "examples";
    rev = "9d6a2e67d29b8b6208d22d70cb22880345bb6803";
    sha256 = "sha256-NQqXsmX7hyTqLINkz1rnavx15jQTdIKpotw42rGc5mc=";
  };
in
{
  cpp = bazelPackage {
    inherit src registry;
    nativeBuildInputs = lib.optional (stdenv.hostPlatform.isDarwin) cctools;

    env = {
      USE_BAZEL_VERSION = bazel_8.version;
    };

    installPhase = ''
      mkdir $out
      cp bazel-bin/main/hello-world $out/
    '';

    bazel = bazel_8;

    bazelRepoCacheFOD = {
      outputHash =
        {
          aarch64-darwin = "sha256-l6qJU0zGIKl12TYYsG5b+upswUA0hGE+VtQ9QnKpBh8=";
          aarch64-linux = "sha256-l6qJU0zGIKl12TYYsG5b+upswUA0hGE+VtQ9QnKpBh8=";
          x86_64-linux = "sha256-l6qJU0zGIKl12TYYsG5b+upswUA0hGE+VtQ9QnKpBh8=";
        }
        .${stdenv.hostPlatform.system};

      outputHashAlgo = "sha256";
    };

    commandArgs = lib.optionals (stdenv.hostPlatform.isDarwin) [
      "--host_cxxopt=-xc++"
      "--cxxopt=-xc++"
    ];

    name = "cpp-tutorial";
    sourceRoot = "source/cpp-tutorial/stage3";
    targets = [ "//main:hello-world" ];
  };

  java = bazelPackage {
    inherit src registry;
    nativeBuildInputs = lib.optional (stdenv.hostPlatform.isDarwin) cctools;

    env = {
      JAVA_HOME = jdk_headless.home;
      USE_BAZEL_VERSION = bazel_8.version;
    };

    installPhase = ''
      mkdir $out
      cp bazel-bin/ProjectRunner.jar $out/
    '';

    bazel = bazel_8;

    bazelRepoCacheFOD = {
      outputHash =
        {
          aarch64-darwin = "sha256-FwHsg9P65Eu/n8PV7UW90bvBNG+U67zizRy6Krk32Yg=";
          aarch64-linux = "sha256-W8h2tCIauGnEvPpXje19bZUE/izHaCQ0Wj4nMaP3nkc=";
          x86_64-linux = "sha256-VBckTQAK5qeyi2ublk+Dcga5O5XZg3bfHR6Yaw6vSp0=";
        }
        .${stdenv.hostPlatform.system};

      outputHashAlgo = "sha256";
    };

    commandArgs = [
      "--extra_toolchains=@@rules_java++toolchains+local_jdk//:all"
      "--tool_java_runtime_version=local_jdk_21"
    ];

    name = "java-tutorial";
    sourceRoot = "source/java-tutorial";
    targets = [ "//:ProjectRunner" ];
  };

  rust = bazelPackage {
    inherit src registry;
    nativeBuildInputs = lib.optional (stdenv.hostPlatform.isDarwin) cctools;

    buildInputs = [
      zlib
      libgcc
    ];

    env = {
      USE_BAZEL_VERSION = bazel_8.version;
    };

    installPhase = ''
      mkdir $out
      cp bazel-bin/bin $out/hello-world
    '';

    autoPatchelfIgnoreMissingDeps = [ "librustc_driver-*.so" ];
    bazel = bazel_8;

    bazelVendorDepsFOD = {
      outputHash =
        {
          aarch64-darwin = "sha256-50cAS1okGT1Mq3+TNLk2dk6OdBOAF2LdcskcYuVNOSY=";
          aarch64-linux = "sha256-2Oia7+2nzLrWeo/bK/5L7du5Y30DY+S0jit6e1ixJXw=";
          x86_64-linux = "sha256-kBnSlFRfYsotZTRMrTNhk8/106+BLzwuU6MIRXlD1jE=";
        }
        .${stdenv.hostPlatform.system};

      outputHashAlgo = "sha256";
    };

    name = "rust-examples-01-hello-world";
    sourceRoot = "source/rust-examples/01-hello-world";
    targets = [ "//:bin" ];
  };
}
