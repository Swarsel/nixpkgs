{
  lib,
  stdenv,
  fetchFromGitHub,
  addDriverRunpath,
  buildGoModule,
  callPackages,
  clblast,
  cmake,
  config,
  cudaPackages,
  curl,
  espeak-ng,
  # needed for audio-to-text
  ffmpeg,
  fmt,
  grpc,
  llama-cpp,
  makeWrapper,
  ncurses,
  ocl-icd,
  onnxruntime,
  openblas,
  opencl-headers,
  opencv,
  openssl,
  piper-tts,
  pkg-config,
  protobuf,
  protoc-gen-go,
  protoc-gen-go-grpc,
  sonic,
  spdlog,
  upx,
  which,
  # apply feature parameter names according to
  # https://github.com/NixOS/rfcs/pull/169
  # CPU extensions
  enable_avx ? stdenv.hostPlatform.isx86_64,
  enable_avx2 ? stdenv.hostPlatform.isx86_64,
  enable_avx512 ? stdenv.hostPlatform.avx512Support,
  enable_f16c ? stdenv.hostPlatform.isx86_64,
  enable_fma ? stdenv.hostPlatform.isx86_64,
  enable_upx ? true,
  with_clblas ? false,
  with_cublas ? config.cudaSupport,
  with_openblas ? false,
  with_tts ? true,
  with_vulkan ? false,
}:
let
  BUILD_TYPE =
    assert
      (lib.count lib.id [
        with_openblas
        with_cublas
        with_clblas
        with_vulkan
      ]) <= 1;
    if with_openblas then
      "openblas"
    else if with_cublas then
      "cublas"
    else if with_clblas then
      "clblas"
    else
      "";

  inherit (cudaPackages)
    libcublas
    cuda_nvcc
    cccl
    cuda_cudart
    libcufft
    ;

  llama-cpp-rpc =
    (llama-cpp-grpc.overrideAttrs (prev: {
      cmakeFlags = prev.cmakeFlags ++ [
        (lib.cmakeBool "GGML_AVX" false)
        (lib.cmakeBool "GGML_AVX2" false)
        (lib.cmakeBool "GGML_AVX512" false)
        (lib.cmakeBool "GGML_FMA" false)
        (lib.cmakeBool "GGML_F16C" false)
      ];

      name = "llama-cpp-rpc";
    })).override
      {
        blasSupport = false;
        cudaSupport = false;
        openclSupport = false;
        rpcSupport = true;
        vulkanSupport = false;
      };

  llama-cpp-grpc =
    (llama-cpp.overrideAttrs (
      final: prev: {
        src = fetchFromGitHub {
          owner = "ggerganov";
          repo = "llama.cpp";
          rev = "d6d2c2ab8c8865784ba9fef37f2b2de3f2134d33";
          hash = "sha256-b9B5I3EbBFrkWc6RLXMWcCRKayyWjlGuQrogUcrISrc=";
          fetchSubmodules = true;
        };

        postPatch = ''
          cd examples
          cp -r --no-preserve=mode ${src}/backend/cpp/llama grpc-server
          cp llava/clip* llava/llava.* grpc-server
          printf "\nadd_subdirectory(grpc-server)" >> CMakeLists.txt

          cp ${src}/backend/backend.proto grpc-server
          sed -i grpc-server/CMakeLists.txt \
            -e '/get_filename_component/ s;[.\/]*backend/;;' \
            -e '$a\install(TARGETS ''${TARGET} RUNTIME)'
          cd ..
        '';

        buildInputs = prev.buildInputs ++ [
          protobuf # provides also abseil_cpp as propagated build input
          grpc
          openssl
          curl
        ];

        cmakeFlags = prev.cmakeFlags ++ [
          (lib.cmakeBool "BUILD_SHARED_LIBS" false)
          (lib.cmakeBool "GGML_AVX" enable_avx)
          (lib.cmakeBool "GGML_AVX2" enable_avx2)
          (lib.cmakeBool "GGML_AVX512" enable_avx512)
          (lib.cmakeBool "GGML_FMA" enable_fma)
          (lib.cmakeBool "GGML_F16C" enable_f16c)
        ];

        name = "llama-cpp-grpc";
      }
    )).override
      {
        blasSupport = with_openblas;
        cudaSupport = with_cublas;
        openclSupport = with_clblas;
        rocmSupport = false;
        vulkanSupport = with_vulkan;
      };

  espeak-ng' = espeak-ng.overrideAttrs (self: {
    inherit (go-piper) src;
    patches = [ ];
    nativeBuildInputs = [ cmake ];

    cmakeFlags = (self.cmakeFlags or [ ]) ++ [
      (lib.cmakeBool "BUILD_SHARED_LIBS" true)
      (lib.cmakeBool "USE_ASYNC" false)
      (lib.cmakeBool "USE_MBROLA" false)
      (lib.cmakeBool "USE_LIBPCAUDIO" false)
      (lib.cmakeBool "USE_KLATT" false)
      (lib.cmakeBool "USE_SPEECHPLAYER" false)
      (lib.cmakeBool "USE_LIBSONIC" false)
      (lib.cmakeBool "CMAKE_POSITION_INDEPENDENT_CODE" true)
    ];

    preConfigure = null;
    postInstall = null;
    name = "espeak-ng'";
    sourceRoot = "${go-piper.src.name}/espeak";
  });

  piper-phonemize = stdenv.mkDerivation {
    inherit (go-piper) src;

    nativeBuildInputs = [
      cmake
      pkg-config
    ];

    buildInputs = [
      espeak-ng'
      onnxruntime
    ];

    cmakeFlags = [
      (lib.cmakeFeature "ONNXRUNTIME_DIR" "${onnxruntime.dev}")
      (lib.cmakeFeature "ESPEAK_NG_DIR" "${espeak-ng'}")
    ];

    name = "piper-phonemize";
    sourceRoot = "${go-piper.src.name}/piper-phonemize";
    passthru.espeak-ng = espeak-ng';
  };

  piper-tts' = piper-tts.overrideAttrs (self: {
    inherit (go-piper) src;
    installPhase = null;

    postInstall = ''
      cp CMakeFiles/piper.dir/src/cpp/piper.cpp.o $out/piper.o
      cd $out
      mkdir bin lib
      mv lib*so* lib/
      mv piper piper_phonemize bin/
      rm -rf cmake pkgconfig espeak-ng-data *.ort
    '';

    name = "piper-tts'";
    sourceRoot = "${go-piper.src.name}/piper";
  });

  go-piper = stdenv.mkDerivation {
    src = fetchFromGitHub {
      owner = "mudler";
      repo = "go-piper";
      rev = "e10ca041a885d4a8f3871d52924b47792d5e5aa0";
      hash = "sha256-Yv9LQkWwGpYdOS0FvtP0vZ0tRyBAx27sdmziBR4U4n8=";
      fetchSubmodules = true;
    };

    postPatch = ''
      sed -i Makefile \
        -e '/CXXFLAGS *= / s;$; -DSPDLOG_FMT_EXTERNAL=1;'
    '';

    buildInputs = [
      piper-tts'
      espeak-ng'
      piper-phonemize
      sonic
      fmt
      spdlog
      onnxruntime
    ];

    buildFlags = [ "libpiper_binding.a" ];

    installPhase = ''
      cp -r --no-preserve=mode $src $out
      mkdir -p $out/piper-phonemize/pi
      cp -r --no-preserve=mode ${piper-phonemize}/share $out/piper-phonemize/pi
      cp *.a $out
    '';

    name = "go-piper";

    postUnpack = ''
      cp -r --no-preserve=mode ${piper-tts'}/* source
    '';
  };

  # try to merge with openai-whisper-cpp in future
  whisper-cpp = effectiveStdenv.mkDerivation {
    src = fetchFromGitHub {
      owner = "ggerganov";
      repo = "whisper.cpp";
      rev = "6266a9f9e56a5b925e9892acf650f3eb1245814d";
      hash = "sha256-y30ZccpF3SCdRGa+P3ddF1tT1KnvlI4Fexx81wZxfTk=";
    };

    nativeBuildInputs = [
      cmake
      pkg-config
    ]
    ++ lib.optionals with_cublas [ cuda_nvcc ];

    buildInputs =
      [ ]
      ++ lib.optionals with_cublas [
        cccl
        cuda_cudart
        libcublas
        libcufft
      ]
      ++ lib.optionals with_clblas [
        clblast
        ocl-icd
        opencl-headers
      ]
      ++ lib.optionals with_openblas [ openblas.dev ];

    cmakeFlags = [
      (lib.cmakeBool "WHISPER_CUDA" with_cublas)
      (lib.cmakeBool "WHISPER_CLBLAST" with_clblas)
      (lib.cmakeBool "WHISPER_OPENBLAS" with_openblas)
      (lib.cmakeBool "WHISPER_NO_AVX" (!enable_avx))
      (lib.cmakeBool "WHISPER_NO_AVX2" (!enable_avx2))
      (lib.cmakeBool "WHISPER_NO_FMA" (!enable_fma))
      (lib.cmakeBool "WHISPER_NO_F16C" (!enable_f16c))
      (lib.cmakeBool "BUILD_SHARED_LIBS" false)
    ];

    postInstall = ''
      install -Dt $out/bin bin/*
    '';

    name = "whisper-cpp";
  };

  bark = stdenv.mkDerivation {
    src = fetchFromGitHub {
      owner = "PABannier";
      repo = "bark.cpp";
      tag = "v1.0.0";
      hash = "sha256-wOcggRWe8lsUzEj/wqOAUlJVypgNFmit5ISs9fbwoCE=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ cmake ];

    installPhase = ''
      mkdir -p $out/build
      cp -ra $src/* $out
      find . \( -name '*.a' -or -name '*.c.o' \) -print0 \
        | tar cf - --null --files-from - \
        | tar xf - -C $out/build
    '';

    name = "bark";
  };

  stable-diffusion = stdenv.mkDerivation {
    src = fetchFromGitHub {
      owner = "richiejp";
      repo = "stable-diffusion.cpp";
      rev = "53e3b17eb3d0b5760ced06a1f98320b68b34aaae"; # branch cuda-fix
      hash = "sha256-z56jafOdibpX+XhRsrc7ieGbeug4bf737/UobqkpBV0=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ cmake ];
    buildInputs = [ opencv ];

    cmakeFlags = [
      (lib.cmakeFeature "GGML_BUILD_NUMBER" "1")
    ];

    installPhase = ''
      mkdir -p $out/build
      cp -ra $src/* $out
      find . \( -name '*.a' -or -name '*.c.o' \) -print0 \
        | tar cf - --null --files-from - \
        | tar xf - -C $out/build
    '';

    name = "stable-diffusion";
  };

  GO_TAGS = lib.optional with_tts "tts";

  effectiveStdenv =
    if with_cublas then
      # It's necessary to consistently use backendStdenv when building with CUDA support,
      # otherwise we get libstdc++ errors downstream.
      cudaPackages.backendStdenv
    else
      stdenv;

  pname = "local-ai";
  version = "2.28.0";
  src = fetchFromGitHub {
    owner = "mudler";
    repo = "LocalAI";
    tag = "v${version}";
    hash = "sha256-Hpz0dGkgasSY/FGO7mDzqsLjXut0LdQ9PUXGaURUOlY=";
  };

  prepare-sources =
    let
      cp = "cp -r --no-preserve=mode,ownership";
    in
    ''
      mkdir sources
      ${cp} ${if with_tts then go-piper else go-piper.src} sources/go-piper
      ${cp} ${whisper-cpp.src} sources/whisper.cpp
      cp ${whisper-cpp}/lib/lib*.a sources/whisper.cpp
      ${cp} ${bark} sources/bark.cpp
      ${cp} ${stable-diffusion} sources/stablediffusion-ggml.cpp
    '';

  self = buildGoModule.override { stdenv = effectiveStdenv; } {
    inherit pname version src;

    postPatch = ''
      # TODO: add silero-vad
      sed -i Makefile \
        -e '/mod download/ d' \
        -e '/^ALL_GRPC_BACKENDS+=backend-assets\/grpc\/llama-cpp-avx/ d' \
        -e '/^ALL_GRPC_BACKENDS+=backend-assets\/grpc\/llama-cpp-cuda/ d' \
        -e '/^ALL_GRPC_BACKENDS+=backend-assets\/grpc\/silero-vad/ d' \

      sed -i backend/go/image/stablediffusion-ggml/Makefile \
        -e '/^libsd/ s,$, $(COMBINED_LIB),'

    ''
    + lib.optionalString with_cublas ''
      sed -i Makefile \
        -e '/^CGO_LDFLAGS_WHISPER?=/ s;$;-L${libcufft}/lib -L${cuda_cudart}/lib;'
    '';

    nativeBuildInputs = [
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc
      makeWrapper
      ncurses # tput
      which
    ]
    ++ lib.optional enable_upx upx
    ++ lib.optionals with_cublas [ cuda_nvcc ];

    buildInputs =
      [ ]
      ++ lib.optionals with_cublas [
        cuda_cudart
        libcublas
        libcufft
      ]
      ++ lib.optionals with_clblas [
        clblast
        ocl-icd
        opencl-headers
      ]
      ++ lib.optionals with_openblas [ openblas.dev ]
      ++ lib.optionals with_tts go-piper.buildInputs;

    vendorHash = "sha256-1OY/y1AeL0K+vOU4Jk/cj7rToVLC9EkkNhgifB+icDM=";

    makeFlags = [
      "VERSION=v${version}"
      "BUILD_TYPE=${BUILD_TYPE}"
    ]
    ++ lib.optional with_cublas "CUDA_LIBPATH=${cuda_cudart}/lib"
    ++ lib.optional with_tts "PIPER_CGO_CXXFLAGS=-DSPDLOG_FMT_EXTERNAL=1";

    # should be passed as makeFlags, but build system failes with strings
    # containing spaces
    env.GO_TAGS = builtins.concatStringsSep " " GO_TAGS;
    env.NIX_CFLAGS_COMPILE = " -isystem ${opencv}/include/opencv4";

    postConfigure = prepare-sources + ''
      shopt -s extglob
      mkdir -p backend-assets/grpc
      cp ${llama-cpp-grpc}/bin/grpc-server backend-assets/grpc/llama-cpp-fallback
      cp ${llama-cpp-rpc}/bin/grpc-server backend-assets/grpc/llama-cpp-grpc

      mkdir -p backend/cpp/llama/llama.cpp

      mkdir -p backend-assets/util
      cp ${llama-cpp-rpc}/bin/llama-rpc-server backend-assets/util/llama-cpp-rpc-server

      cp -r --no-preserve=mode,ownership ${stable-diffusion}/build backend/go/image/stablediffusion-ggml/build

      # avoid rebuild of prebuilt make targets
      touch backend-assets/grpc/* backend-assets/util/*
      find sources -name "lib*.a" -exec touch {} +
    '';

    buildPhase = ''
      runHook preBuild

      local flagsArray=(
        ''${enableParallelBuilding:+-j''${NIX_BUILD_CORES}}
        SHELL=$SHELL
      )

      # copy from Makefile:258
      make -C backend/go/image/stablediffusion-ggml libsd.a

      concatTo flagsArray makeFlags makeFlagsArray buildFlags buildFlagsArray
      echoCmd 'build flags' "''${flagsArray[@]}"
      make build "''${flagsArray[@]}"
      unset flagsArray

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dt $out/bin ${pname}

      runHook postInstall
    '';

    # patching rpath with patchelf doens't work. The executable
    # raises an segmentation fault
    postFixup =
      let
        LD_LIBRARY_PATH =
          [ ]
          ++ lib.optionals with_cublas [
            # driverLink has to be first to avoid loading the stub version of libcuda.so
            # https://github.com/NixOS/nixpkgs/issues/320145#issuecomment-2190319327
            addDriverRunpath.driverLink
            (lib.getLib libcublas)
            cuda_cudart
          ]
          ++ lib.optionals with_clblas [
            clblast
            ocl-icd
          ]
          ++ lib.optionals with_openblas [ openblas ]
          ++ lib.optionals with_tts [ piper-phonemize ]
          ++ lib.optionals (with_tts && enable_upx) [
            fmt
            spdlog
          ];
      in
      ''
        wrapProgram $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath LD_LIBRARY_PATH}" \
        --prefix PATH : "${ffmpeg}/bin"
      '';

    enableParallelBuilding = false;

    modBuildPhase = prepare-sources + ''
      make protogen-go
      go mod tidy -v
    '';

    proxyVendor = true;

    passthru.features = {
      inherit
        with_cublas
        with_openblas
        with_vulkan
        with_tts
        with_clblas
        ;
    };

    passthru.lib = callPackages ./lib.nix { };

    passthru.local-packages = {
      inherit
        go-piper
        llama-cpp-grpc
        whisper-cpp
        espeak-ng'
        piper-phonemize
        piper-tts'
        llama-cpp-rpc
        bark
        stable-diffusion
        ;
    };

    passthru.tests = callPackages ./tests.nix { inherit self; };

    meta = {
      description = "OpenAI alternative to run local LLMs, image and audio generation";
      homepage = "https://localai.io";
      license = lib.licenses.mit;

      maintainers = with lib.maintainers; [
        onny
        ck3d
      ];

      platforms = lib.platforms.linux;
      mainProgram = "local-ai";
      # Doesn't build with >buildGo123Module.
      # 'cp: cannot stat 'bin/rpc-server': No such file or directory'
      broken = true;
    };
  };
in
self
