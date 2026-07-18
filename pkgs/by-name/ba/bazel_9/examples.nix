{
  lib,
  stdenv,
  fetchFromGitHub,
  bazel_9,
  callPackage,
  cctools,
  jdk_headless,
  libgcc,
  libxcrypt-legacy,
  zlib,
}:
let
  bazelPackage = callPackage ./build-support/bazelPackage.nix { };
  registry = fetchFromGitHub {
    owner = "bazelbuild";
    repo = "bazel-central-registry";
    rev = "0e9e0cfdb88577300cc369d0cbe81e678d0fb271";
    sha256 = "sha256-YAR0tYVUdITfW/2H/LZky88nyoWTsgZf/CX4BtJ/Mwk=";
  };
  src = fetchFromGitHub {
    owner = "bazelbuild";
    repo = "examples";
    rev = "2a8db5804341036b393ff7e1ba88edb30c8a82c7";
    sha256 = "sha256-/+rU73WPIKguoEOJDCodE3pUGSGju0VhixIcr0zBVmY=";
  };
  inherit (callPackage ./build-support/patching.nix { }) addFilePatch;
in
{
  cpp = bazelPackage {
    inherit src registry;

    patches = [
      ./patches/examples/cpp-tutorial.patch
      (addFilePatch {
        file = ./patches/examples/rules_cc.patch;
        path = "b/rules_cc.patch";
      })
    ];

    nativeBuildInputs = lib.optional (stdenv.hostPlatform.isDarwin) cctools;

    env = {
      USE_BAZEL_VERSION = bazel_9.version;
    };

    installPhase = ''
      mkdir $out
      cp bazel-bin/main/hello-world $out/
    '';

    bazel = bazel_9;

    bazelRepoCacheFOD = {
      outputHash =
        {
          aarch64-darwin = "sha256-CbA4Kcn6656xnK6DkN4TZ7u1/mizA49Im9hRCU86TGs=";
          aarch64-linux = "sha256-CbA4Kcn6656xnK6DkN4TZ7u1/mizA49Im9hRCU86TGs=";
          x86_64-linux = "sha256-CbA4Kcn6656xnK6DkN4TZ7u1/mizA49Im9hRCU86TGs=";
        }
        .${stdenv.hostPlatform.system};

      outputHashAlgo = "sha256";
    };

    commandArgs = lib.optionals (stdenv.hostPlatform.isDarwin) [
      "--host_cxxopt=-xc++"
      "--cxxopt=-xc++"
      "--spawn_strategy=local"
    ];

    name = "cpp-tutorial";
    sourceRoot = "source/cpp-tutorial/stage3";
    targets = [ "//main:hello-world" ];
  };

  java = bazelPackage {
    inherit src registry;

    patches = [
      ./patches/examples/java-tutorial.patch
      (addFilePatch {
        file = ./patches/examples/rules_cc.patch;
        path = "b/rules_cc.patch";
      })
    ];

    nativeBuildInputs = lib.optional (stdenv.hostPlatform.isDarwin) cctools;

    buildInputs = [
      libgcc
      libxcrypt-legacy
      stdenv.cc.cc.lib
    ];

    env = {
      JAVA_HOME = jdk_headless.home;
      USE_BAZEL_VERSION = bazel_9.version;
    };

    installPhase = ''
      mkdir $out
      cp bazel-bin/ProjectRunner.jar $out/
    '';

    bazel = bazel_9;

    bazelVendorDepsFOD = {
      outputHash =
        {
          aarch64-darwin = "sha256-Jth981+r20azC/CqoWN3LK5USm8zUIpL9Xt88+TcL1o=";
          aarch64-linux = "sha256-4E/QCSOXTN/dW65xz/n47tXW0PlHUOP1UP+TwJfMueI=";
          x86_64-linux = "sha256-HzgFpbEBZ8efA5pwUsGZjt9bKiAXslB17OZQcm3cspc=";
        }
        .${stdenv.hostPlatform.system};

      outputHashAlgo = "sha256";
    };

    commandArgs = [
      "--extra_toolchains=@@rules_java++toolchains+local_jdk//:all"
      "--tool_java_runtime_version=local_jdk_21"
    ]
    ++ lib.optional stdenv.hostPlatform.isDarwin "--spawn_strategy=local";

    name = "java-tutorial";
    sourceRoot = "source/java-tutorial";
    targets = [ "//:ProjectRunner" ];
  };

  rust = bazelPackage {
    inherit src registry;

    patches = [
      ./patches/examples/rust-examples.patch
      (addFilePatch {
        file = ./patches/examples/rules_cc.patch;
        path = "b/rules_cc.patch";
      })
    ];

    nativeBuildInputs = lib.optional (stdenv.hostPlatform.isDarwin) cctools;

    buildInputs = [
      zlib
      libgcc
    ];

    env = {
      USE_BAZEL_VERSION = bazel_9.version;
    };

    installPhase = ''
      mkdir $out
      cp bazel-bin/bin $out/hello-world
    '';

    autoPatchelfIgnoreMissingDeps = [ "librustc_driver-*.so" ];
    bazel = bazel_9;

    bazelVendorDepsFOD = {
      outputHash =
        {
          aarch64-darwin = "sha256-uUl7PpR3jAKvj6VWspPE3IR4Gr/V2VrBv1MlTzOIZJs=";
          aarch64-linux = "sha256-uhcIwDk8NAZDBynzxWk+0fLP/2XadKQRl5BlFPjf4/8=";
          x86_64-linux = "sha256-YURF8Zjueq3BN5GfEx5L+C4hGmr5qfJc7OngqZ17384=";
        }
        .${stdenv.hostPlatform.system};

      outputHashAlgo = "sha256";
    };

    commandArgs = lib.optional stdenv.hostPlatform.isDarwin "--spawn_strategy=local";
    name = "rust-examples-01-hello-world";
    sourceRoot = "source/rust-examples/01-hello-world";
    targets = [ "//:bin" ];
  };
}
