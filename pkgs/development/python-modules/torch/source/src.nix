{
  fetchFromGitHub,
  fetchFromGitLab,
  runCommand,
  version,
}:
assert version == "2.12.0";
rec {
  src_DCGM = fetchFromGitHub {
    hash = "sha256-jlnq25byEep7wRF3luOIGaiaYjqSVaTBx02N6gE/ox8=";
    owner = "NVIDIA";
    repo = "DCGM";
    rev = "ffde4e54bc7249a6039a5e6b45b395141e1217f9";
  };

  src_DCGM_recursive = src_DCGM;

  src_FP16 = fetchFromGitHub {
    hash = "sha256-B27LtVnL52niaFgPW0pp5Uulub/Q3NvtSDkJNahrSBk=";
    owner = "Maratyszcza";
    repo = "FP16";
    rev = "4dfe081cf6bcd15db339cf2680b9281b8451eeb3";
  };

  src_FP16_recursive = src_FP16;

  src_FXdiv = fetchFromGitHub {
    hash = "sha256-BEjscsejYVhRxDAmah5DT3+bglp8G5wUTTYL7+HjWds=";
    owner = "Maratyszcza";
    repo = "FXdiv";
    rev = "b408327ac2a15ec3e43352421954f5b1967701d1";
  };

  src_FXdiv_recursive = src_FXdiv;

  src_MSLK = fetchFromGitHub {
    hash = "sha256-iuwAI8ko4yzifjoqKLxtz6UFOAOoWhsw4+3Unkiv6aE=";
    owner = "meta-pytorch";
    repo = "MSLK";
    rev = "3d332d1c0c0ac7765852c97b3979c9ef913e037f";
  };

  src_MSLK_recursive = runCommand "MSLK" { } ''
    cp -r ${src_MSLK} $out
    chmod u+w $out/external/composable_kernel
    cp -r ${src_composable_kernel_fbgemm_MSLK_recursive}/* $out/external/composable_kernel
    chmod u+w $out/external/cutlass
    cp -r ${src_cutlass_MSLK_recursive}/* $out/external/cutlass
    chmod u+w $out/external/googletest
    cp -r ${src_googletest_recursive}/* $out/external/googletest
    chmod u+w $out/external/hipify_torch
    cp -r ${src_hipify_torch_recursive}/* $out/external/hipify_torch
  '';

  src_NNPACK = fetchFromGitHub {
    hash = "sha256-GzF53u1ELtmEH3WbBzGBemlQhjj3EIKB+37wMtSYE2g=";
    owner = "Maratyszcza";
    repo = "NNPACK";
    rev = "c07e3a0400713d546e0dea2d5466dd22ea389c73";
  };

  src_NNPACK_recursive = src_NNPACK;

  src_NVTX = fetchFromGitHub {
    hash = "sha256-F1TD1lK0sE6UWMhelF1q147T5Jk3xFUHwsmKoE+WnXY=";
    owner = "NVIDIA";
    repo = "NVTX";
    rev = "3ebbc93ded7285963bff932c678fa367eb393ba6";
  };

  src_NVTX_recursive = src_NVTX;

  src_PeachPy = fetchFromGitHub {
    hash = "sha256-eyhfnOOZPtsJwjkF6ybv3F77fyjaV6wzgu+LxadZVw0=";
    owner = "malfet";
    repo = "PeachPy";
    rev = "f45429b087dd7d5bc78bb40dc7cf06425c252d67";
  };

  src_PeachPy_recursive = src_PeachPy;

  src_VulkanMemoryAllocator = fetchFromGitHub {
    hash = "sha256-TPEqV8uHbnyphLG0A+b2tgLDQ6K7a2dOuDHlaFPzTeE=";
    owner = "GPUOpen-LibrariesAndSDKs";
    repo = "VulkanMemoryAllocator";
    rev = "1d8f600fd424278486eade7ed3e877c99f0846b1";
  };

  src_VulkanMemoryAllocator_recursive = src_VulkanMemoryAllocator;

  src_XNNPACK = fetchFromGitHub {
    hash = "sha256-nhowllqv/hBs7xHdTwbWtiKJ1mvAYsVIyIZ35ZGsmkg=";
    owner = "google";
    repo = "XNNPACK";
    rev = "51a0103656eff6fc9bfd39a4597923c4b542c883";
  };

  src_XNNPACK_recursive = src_XNNPACK;

  src_aiter = fetchFromGitHub {
    hash = "sha256-kaX3uAkgE99puYu+ODdKjvsN+LLl1Jt95vtd5Xh0Mg8=";
    owner = "ROCm";
    repo = "aiter";
    rev = "9a469a608b2c10b7157df573a38d31e5bf4038b4";
  };

  src_aiter_recursive = runCommand "aiter" { } ''
    cp -r ${src_aiter} $out
    chmod u+w $out/3rdparty/composable_kernel
    cp -r ${src_composable_kernel_aiter_recursive}/* $out/3rdparty/composable_kernel
  '';

  src_asmjit = fetchFromGitHub {
    hash = "sha256-qb0lM1N1FIvoADNsZZdlg8HAheePv/LvSDvRhOAqZc0=";
    owner = "asmjit";
    repo = "asmjit";
    rev = "a3199e8857792cd10b7589ff5d58343d2c9008ea";
  };

  src_asmjit_recursive = src_asmjit;

  src_benchmark = fetchFromGitHub {
    hash = "sha256-iPK3qLrZL2L08XW1a7SGl7GAt5InQ5nY+Dn8hBuxSOg=";
    owner = "google";
    repo = "benchmark";
    rev = "299e5928955cc62af9968370293b916f5130916f";
  };

  src_benchmark_protobuf = fetchFromGitHub {
    hash = "sha256-iFRgjLkftuszAqBnmS9GXU8BwYnabmwMAQyw19sfjb4=";
    owner = "google";
    repo = "benchmark";
    rev = "5b7683f49e1e9223cf9927b24f6fd3d6bd82e3f8";
  };

  src_benchmark_protobuf_recursive = src_benchmark_protobuf;
  src_benchmark_recursive = src_benchmark;

  src_civetweb = fetchFromGitHub {
    hash = "sha256-eXb5f2jhtfxDORG+JniSy17kzB7A4vM0UnUQAfKTquU=";
    owner = "civetweb";
    repo = "civetweb";
    rev = "d7ba35bbb649209c66e582d5a0244ba988a15159";
  };

  src_civetweb_recursive = src_civetweb;

  src_clang-cindex-python3 = fetchFromGitHub {
    hash = "sha256-IDUIuAvgCzWaHoTJUZrH15bqoVcP8bZk+Gs1Ae6/CpY=";
    owner = "wjakob";
    repo = "clang-cindex-python3";
    rev = "6a00cbc4a9b8e68b71caf7f774b3f9c753ae84d5";
  };

  src_clang-cindex-python3_recursive = src_clang-cindex-python3;

  src_composable_kernel = fetchFromGitHub {
    hash = "sha256-B/xNuBPUdjL1b+0IzRnaSXT2FKUo5cYwYcKqfKqJ8Eg=";
    owner = "ROCm";
    repo = "composable_kernel";
    rev = "f1746955fdaf80a3414de814bf32437686dac347";
  };

  src_composable_kernel_aiter = fetchFromGitHub {
    hash = "sha256-Xwj48Ftwqlea5ZIP7q7cRh2U2tlHTd1cdW4TYf5J0Dg=";
    owner = "ROCm";
    repo = "composable_kernel";
    rev = "fcc9372c009c8e0a23fece77b582da83b04a654f";
  };

  src_composable_kernel_aiter_recursive = src_composable_kernel_aiter;

  src_composable_kernel_fbgemm_MSLK = fetchFromGitHub {
    hash = "sha256-OxA0ekcaRxAmBFlXkvS7XAX40kcWCwyytHWV6vROWjo=";
    owner = "ROCm";
    repo = "composable_kernel";
    rev = "7fe50dc3da2069d6645d9deb8c017a876472a977";
  };

  src_composable_kernel_fbgemm_MSLK_recursive = src_composable_kernel_fbgemm_MSLK;

  src_composable_kernel_flash-attention = fetchFromGitHub {
    hash = "sha256-nS1Apx4kLTIz7U2/X1BVQHiBwa5j59VboaibOhH9ADM=";
    owner = "ROCm";
    repo = "composable_kernel";
    rev = "13f6d635653bd5ffbfcac8577f1ef09590c23d78";
  };

  src_composable_kernel_flash-attention_recursive = src_composable_kernel_flash-attention;
  src_composable_kernel_recursive = src_composable_kernel;

  src_cpp-httplib = fetchFromGitHub {
    hash = "sha256-VXEhoxoQjGEuA2g/y6fDTA4LrPd4SggrS3aOjznDSvc=";
    owner = "yhirose";
    repo = "cpp-httplib";
    rev = "4d7c9a788de136071ccf0dd4e96239151e2adadb";
  };

  src_cpp-httplib_recursive = src_cpp-httplib;

  src_cpr = fetchFromGitHub {
    hash = "sha256-TxoDCIa7pS+nfI8hNiGIRQKpYNrKSd1yCXPfVXPcRW8=";
    owner = "libcpr";
    repo = "cpr";
    rev = "871ed52d350214a034f6ef8a3b8f51c5ce1bd400";
  };

  src_cpr_recursive = src_cpr;

  src_cpuinfo = fetchFromGitHub {
    hash = "sha256-9eXqsdgGl4oZEC8uJgiyqrvD3HVyUuNcSkJ8VTmZBj8=";
    owner = "pytorch";
    repo = "cpuinfo";
    rev = "f858c30bcb16f8effd5ff46996f0514539e17abc";
  };

  src_cpuinfo_fbgemm = fetchFromGitHub {
    hash = "sha256-uzo6QpNfzTcqOpDse14e2OoxNyKDU8jSx+/wPLxmpJg=";
    owner = "pytorch";
    repo = "cpuinfo";
    rev = "161a9ec374884f4b3e85725cb22e05f9458fdc93";
  };

  src_cpuinfo_fbgemm_recursive = src_cpuinfo_fbgemm;
  src_cpuinfo_recursive = src_cpuinfo;

  src_cudnn-frontend = fetchFromGitHub {
    hash = "sha256-OOKdkjsVnWgrtcI7IMPSRi2YxtqF2YNV4Fd2rD9I1K8=";
    owner = "NVIDIA";
    repo = "cudnn-frontend";
    rev = "a91f0e04dcea10515f0f776fc5a89535e316a9c8";
  };

  src_cudnn-frontend_recursive = src_cudnn-frontend;

  src_cutlass = fetchFromGitHub {
    hash = "sha256-0q9Ad0Z6E/rO2PdM4uQc8H0E0qs9uKc3reHepiHhjEc=";
    owner = "NVIDIA";
    repo = "cutlass";
    rev = "da5e086dab31d63815acafdac9a9c5893b1c69e2";
  };

  src_cutlass_MSLK = fetchFromGitHub {
    hash = "sha256-EnEtWPJqJBLGOk93HdUL45NFqIVG5qetJX6vnc7K6pE=";
    owner = "jwfromm";
    repo = "cutlass";
    rev = "571edeb2d0ac872a8392fc49285b156b07884b4e";
  };

  src_cutlass_MSLK_recursive = src_cutlass_MSLK;

  src_cutlass_fbgemm = fetchFromGitHub {
    hash = "sha256-me+IKK79OJz4tCioc1GxJxp620KFL4yYk5r85XHj3zQ=";
    owner = "jwfromm";
    repo = "cutlass";
    rev = "a54461186bc30c39bf89bc433f89198892ad9e5f";
  };

  src_cutlass_fbgemm_recursive = src_cutlass_fbgemm;

  src_cutlass_flash-attention = fetchFromGitHub {
    hash = "sha256-/fEfuriQbrjjLP+yRjeo88SgW3IurdlU+6rR9+w5woQ=";
    owner = "NVIDIA";
    repo = "cutlass";
    rev = "7127592069c2fe01b041e174ba4345ef9b279671";
  };

  src_cutlass_flash-attention_recursive = src_cutlass_flash-attention;
  src_cutlass_recursive = src_cutlass;

  src_dynolog = fetchFromGitHub {
    hash = "sha256-AebAZeDE9mXvg1XsgDm/4DIAMDIkbd+HGgcTmxV+HX0=";
    owner = "facebookincubator";
    repo = "dynolog";
    rev = "d2ffe0a4e3acace628db49974246b66fc3e85fb1";
  };

  src_dynolog_recursive = runCommand "dynolog" { } ''
    cp -r ${src_dynolog} $out
    chmod u+w $out/third_party/cpr
    cp -r ${src_cpr_recursive}/* $out/third_party/cpr
    chmod u+w $out/third_party/DCGM
    cp -r ${src_DCGM_recursive}/* $out/third_party/DCGM
    chmod u+w $out/third_party/fmt
    cp -r ${src_fmt_dynolog_recursive}/* $out/third_party/fmt
    chmod u+w $out/third_party/gflags
    cp -r ${src_gflags_recursive}/* $out/third_party/gflags
    chmod u+w $out/third_party/glog
    cp -r ${src_glog_recursive}/* $out/third_party/glog
    chmod u+w $out/third_party/googletest
    cp -r ${src_googletest_recursive}/* $out/third_party/googletest
    chmod u+w $out/third_party/json
    cp -r ${src_json_dynolog_recursive}/* $out/third_party/json
    chmod u+w $out/third_party/pfs
    cp -r ${src_pfs_recursive}/* $out/third_party/pfs
    chmod u+w $out/third_party/prometheus-cpp
    cp -r ${src_prometheus-cpp_recursive}/* $out/third_party/prometheus-cpp
  '';

  src_fbgemm = fetchFromGitHub {
    hash = "sha256-jNc9Z3fe4pUTP5FY3sV1WINoEEd8te6tTyjNsFWZFxY=";
    owner = "pytorch";
    repo = "fbgemm";
    rev = "c246916f9e3804eacc3c95058e51cce02ae00fff";
  };

  src_fbgemm_recursive = runCommand "fbgemm" { } ''
    cp -r ${src_fbgemm} $out
    chmod u+w $out/external/asmjit
    cp -r ${src_asmjit_recursive}/* $out/external/asmjit
    chmod u+w $out/external/composable_kernel
    cp -r ${src_composable_kernel_fbgemm_MSLK_recursive}/* $out/external/composable_kernel
    chmod u+w $out/external/cpuinfo
    cp -r ${src_cpuinfo_fbgemm_recursive}/* $out/external/cpuinfo
    chmod u+w $out/external/cutlass
    cp -r ${src_cutlass_fbgemm_recursive}/* $out/external/cutlass
    chmod u+w $out/external/googletest
    cp -r ${src_googletest_recursive}/* $out/external/googletest
    chmod u+w $out/external/hipify_torch
    cp -r ${src_hipify_torch_recursive}/* $out/external/hipify_torch
    chmod u+w $out/external/json
    cp -r ${src_json_fbgemm_recursive}/* $out/external/json
  '';

  src_fbjni = fetchFromGitHub {
    hash = "sha256-PsgUHtCE3dNR2QdUnRjrXb0ZKZNGwFkA8RWYkZEklEY=";
    owner = "facebookincubator";
    repo = "fbjni";
    rev = "7e1e1fe3858c63c251c637ae41a20de425dde96f";
  };

  src_fbjni_recursive = src_fbjni;

  src_flash-attention = fetchFromGitHub {
    hash = "sha256-7yEFNM2lslkBA/9slblAbiK1PHKqKmo1MCFJYz2BOLk=";
    owner = "Dao-AILab";
    repo = "flash-attention";
    rev = "fec3a6a18460c1b40f097208d4c16fe8964a679d";
  };

  src_flash-attention_recursive = runCommand "flash-attention" { } ''
    cp -r ${src_flash-attention} $out
    chmod u+w $out/csrc/composable_kernel
    cp -r ${src_composable_kernel_flash-attention_recursive}/* $out/csrc/composable_kernel
    chmod u+w $out/csrc/cutlass
    cp -r ${src_cutlass_flash-attention_recursive}/* $out/csrc/cutlass
  '';

  src_flatbuffers = fetchFromGitHub {
    hash = "sha256-6L6Eb+2xGXEqLYITWsNNPW4FTvfPFSmChK4hLusk5gU=";
    owner = "google";
    repo = "flatbuffers";
    rev = "a2cd1ea3b6d3fee220106b5fed3f7ce8da9eb757";
  };

  src_flatbuffers_recursive = src_flatbuffers;

  src_fmt = fetchFromGitHub {
    hash = "sha256-ZmI1Dv0ZabPlxa02OpERI47jp7zFfjpeWCy1WyuPYZ0=";
    owner = "fmtlib";
    repo = "fmt";
    rev = "407c905e45ad75fc29bf0f9bb7c5c2fd3475976f";
  };

  src_fmt_dynolog = fetchFromGitHub {
    hash = "sha256-Ks3UG3V0Pz6qkKYFhy71ZYlZ9CPijO6GBrfMqX5zAp8=";
    owner = "fmtlib";
    repo = "fmt";
    rev = "cd4af11efc9c622896a3e4cb599fa28668ca3d05";
  };

  src_fmt_dynolog_recursive = src_fmt_dynolog;

  src_fmt_kineto = fetchFromGitHub {
    hash = "sha256-sAlU5L/olxQUYcv8euVYWTTB8TrVeQgXLHtXy8IMEnU=";
    owner = "fmtlib";
    repo = "fmt";
    rev = "40626af88bd7df9a5fb80be7b25ac85b122d6c21";
  };

  src_fmt_kineto_recursive = src_fmt_kineto;
  src_fmt_recursive = src_fmt;

  src_gemmlowp = fetchFromGitHub {
    hash = "sha256-G3PAf9j7Tb4dUoaV9Tmxkkfu3v+w0uFbZ+MWS68tlRw=";
    owner = "google";
    repo = "gemmlowp";
    rev = "3fb5c176c17c765a3492cd2f0321b0dab712f350";
  };

  src_gemmlowp_recursive = src_gemmlowp;

  src_gflags = fetchFromGitHub {
    hash = "sha256-4NLd/p72H7ZiFCCVjTfM/rDvZ8CVPMxYpnJ2O1od8ZA=";
    owner = "gflags";
    repo = "gflags";
    rev = "e171aa2d15ed9eb17054558e0b3a6a413bb01067";
  };

  src_gflags_gflags = fetchFromGitHub {
    hash = "sha256-Bb4g64u5a0QRWwDl1ryNXmht6NKFWPW9bAF07yYRJ6I=";
    owner = "gflags";
    repo = "gflags";
    rev = "8411df715cf522606e3b1aca386ddfc0b63d34b4";
  };

  src_gflags_gflags_recursive = src_gflags_gflags;

  src_gflags_recursive = runCommand "gflags" { } ''
    cp -r ${src_gflags} $out
    chmod u+w $out/doc
    cp -r ${src_gflags_gflags_recursive}/* $out/doc
  '';

  src_glog = fetchFromGitHub {
    hash = "sha256-xqRp9vaauBkKz2CXbh/Z4TWqhaUtqfbsSlbYZR/kW9s=";
    owner = "google";
    repo = "glog";
    rev = "b33e3bad4c46c8a6345525fd822af355e5ef9446";
  };

  src_glog_recursive = src_glog;

  src_gloo = fetchFromGitHub {
    hash = "sha256-lCKZyH8p54UaSDGRTxM6ZMorc+japeJulv7FQn0GnHc=";
    owner = "pytorch";
    repo = "gloo";
    rev = "3135b0b41b67dde590eef0938a0bf3d6238df5f7";
  };

  src_gloo_recursive = src_gloo;

  src_googletest = fetchFromGitHub {
    hash = "sha256-HIHMxAUR4bjmFLoltJeIAVSulVQ6kVuIT2Ku+lwAx/4=";
    owner = "google";
    repo = "googletest";
    rev = "52eb8108c5bdec04579160ae17225d66034bd723";
  };

  src_googletest_prometheus-cpp = fetchFromGitHub {
    hash = "sha256-SjlJxushfry13RGA7BCjYC9oZqV4z6x8dOiHfl/wpF0=";
    owner = "google";
    repo = "googletest";
    rev = "e2239ee6043f73722e7aa812a459f54a28552929";
  };

  src_googletest_prometheus-cpp_recursive = src_googletest_prometheus-cpp;

  src_googletest_protobuf = fetchFromGitHub {
    hash = "sha256-Zh7t6kOabEZxIuTwREerNSgbZLPnGWv78h0wQQAIuT4=";
    owner = "google";
    repo = "googletest";
    rev = "5ec7f0c4a113e2f18ac2c6cc7df51ad6afc24081";
  };

  src_googletest_protobuf_recursive = src_googletest_protobuf;
  src_googletest_recursive = src_googletest;

  src_googletest_tensorpipe = fetchFromGitHub {
    hash = "sha256-L2HR+QTQmagk92JiuW3TRx47so33xQvewdeYL1ipUPs=";
    owner = "google";
    repo = "googletest";
    rev = "aee0f9d9b5b87796ee8a0ab26b7587ec30e8858e";
  };

  src_googletest_tensorpipe_recursive = src_googletest_tensorpipe;

  src_hipify_torch = fetchFromGitHub {
    hash = "sha256-TH9fyprP21sRsxGs4VrahhFSIXDhnLvV09c+ZCE27u0=";
    owner = "ROCmSoftwarePlatform";
    repo = "hipify_torch";
    rev = "63b6a7b541fa7f08f8475ca7d74054db36ff2691";
  };

  src_hipify_torch_recursive = src_hipify_torch;

  src_ideep = fetchFromGitHub {
    hash = "sha256-AVSsugGYiQ4QOWMVaHj1hzlPTZmg65yrGMmrWytvUuM=";
    owner = "intel";
    repo = "ideep";
    rev = "e539e0f9774e2018f0d56fe865da66581f692e3d";
  };

  src_ideep_recursive = runCommand "ideep" { } ''
    cp -r ${src_ideep} $out
    chmod u+w $out/mkl-dnn
    cp -r ${src_mkl-dnn_recursive}/* $out/mkl-dnn
  '';

  src_ittapi = fetchFromGitHub {
    hash = "sha256-v6efQEMW1r5fsjOIpJQQPoau6sina/iKxAY1cfEUZQc=";
    owner = "intel";
    repo = "ittapi";
    rev = "0c57540822deb5dae43bef6c1cc9b3be4772a033";
  };

  src_ittapi_recursive = src_ittapi;

  src_json = fetchFromGitHub {
    hash = "sha256-cECvDOLxgX7Q9R3IE86Hj9JJUxraDQvhoyPDF03B2CY=";
    owner = "nlohmann";
    repo = "json";
    rev = "55f93686c01528224f448c19128836e7df245f72";
  };

  src_json_dynolog = fetchFromGitHub {
    hash = "sha256-DTsZrdB9GcaNkx7ZKxcgCA3A9ShM5icSF0xyGguJNbk=";
    owner = "nlohmann";
    repo = "json";
    rev = "4f8fba14066156b73f1189a2b8bd568bde5284c5";
  };

  src_json_dynolog_recursive = src_json_dynolog;

  src_json_fbgemm = fetchFromGitHub {
    hash = "sha256-7F0Jon+1oWL7uqet5i1IgHX0fUw/+z0QwEcA3zs5xHg=";
    owner = "nlohmann";
    repo = "json";
    rev = "9cca280a4d0ccf0c08f47a99aa71d1b0e52f8d03";
  };

  src_json_fbgemm_recursive = src_json_fbgemm;
  src_json_recursive = src_json;

  src_kineto = fetchFromGitHub {
    hash = "sha256-Ix5zulGaUPbLeVrrTm/EzcVWT4TkDYcBsQADAl4N7TA=";
    owner = "pytorch";
    repo = "kineto";
    rev = "b2103f78d13fde4937af010c0ef8e24313568bc5";
  };

  src_kineto_recursive = runCommand "kineto" { } ''
    cp -r ${src_kineto} $out
    chmod u+w $out/libkineto/third_party/dynolog
    cp -r ${src_dynolog_recursive}/* $out/libkineto/third_party/dynolog
    chmod u+w $out/libkineto/third_party/fmt
    cp -r ${src_fmt_kineto_recursive}/* $out/libkineto/third_party/fmt
    chmod u+w $out/libkineto/third_party/googletest
    cp -r ${src_googletest_recursive}/* $out/libkineto/third_party/googletest
  '';

  src_kleidiai = fetchFromGitHub {
    hash = "sha256-5/LkO8ihQCeA6nok68OrzurOcIgjFgXntO1C3By5HUw=";
    owner = "ARM-software";
    repo = "kleidiai";
    rev = "d7770c89632329a9914ef1a90289917597639cbe";
  };

  src_kleidiai_recursive = src_kleidiai;

  src_libnop = fetchFromGitHub {
    hash = "sha256-AsPZt+ylfdGpytQ1RoQljKeXE2uGkGONCaWzLK2sZhA=";
    owner = "google";
    repo = "libnop";
    rev = "910b55815be16109f04f4180e9adee14fb4ce281";
  };

  src_libnop_recursive = src_libnop;

  src_libuv = fetchFromGitHub {
    hash = "sha256-ayTk3qkeeAjrGj5ab7wF7vpWI8XWS1EeKKUqzaD/LY0=";
    owner = "libuv";
    repo = "libuv";
    rev = "5152db2cbfeb5582e9c27c5ea1dba2cd9e10759b";
  };

  src_libuv_recursive = src_libuv;

  src_mimalloc = fetchFromGitHub {
    hash = "sha256-ZxIkzMIqwYZpiqbPAHDrO26xaiaF77Dlosbw43VkOpc=";
    owner = "microsoft";
    repo = "mimalloc";
    rev = "048d969a1c5ee2fb89c226298f41ea38445546ef";
  };

  src_mimalloc_recursive = src_mimalloc;

  src_mkl-dnn = fetchFromGitHub {
    hash = "sha256-xJTllrKs6mPNM85ZqyHTHWKpVOtOghmg4ZRFAvQZ4WU=";
    owner = "intel";
    repo = "mkl-dnn";
    rev = "03c022d3ffdcee958cfacbe720048e725fdf644c";
  };

  src_mkl-dnn_recursive = src_mkl-dnn;

  src_onnx = fetchFromGitHub {
    hash = "sha256-UhtF+CWuyv5/Pq/5agLL4Y95YNP63W2BraprhRqJOag=";
    owner = "onnx";
    repo = "onnx";
    rev = "e709452ef2bbc1d113faf678c24e6d3467696e83";
  };

  src_onnx_recursive = runCommand "onnx" { } ''
    cp -r ${src_onnx} $out
    chmod u+w $out/third_party/pybind11
    cp -r ${src_pybind11_onnx_recursive}/* $out/third_party/pybind11
  '';

  src_pfs = fetchFromGitHub {
    hash = "sha256-VB7/7hi4vZKgpjpgir+CyWIMwoNLHGRIXPJvVOn8Pq4=";
    owner = "dtrugman";
    repo = "pfs";
    rev = "f68a2fa8ea36c783bdd760371411fcb495aa3150";
  };

  src_pfs_recursive = src_pfs;

  src_pocketfft = fetchFromGitHub {
    hash = "sha256-Fu786IHiU6Bl66gZ/UJmqOROjlya3viLyzOxwdZVi9c=";
    owner = "mreineck";
    repo = "pocketfft";
    rev = "0fa0ef591e38c2758e3184c6c23e497b9f732ffa";
  };

  src_pocketfft_recursive = src_pocketfft;

  src_prometheus-cpp = fetchFromGitHub {
    hash = "sha256-Dj+adszXnWHOcZJ/QTOX214N86pjy71tLuPU6bHcMPg=";
    owner = "jupp0r";
    repo = "prometheus-cpp";
    rev = "b1234816facfdda29845c46696a02998a4af115a";
  };

  src_prometheus-cpp_recursive = runCommand "prometheus-cpp" { } ''
    cp -r ${src_prometheus-cpp} $out
    chmod u+w $out/3rdparty/civetweb
    cp -r ${src_civetweb_recursive}/* $out/3rdparty/civetweb
    chmod u+w $out/3rdparty/googletest
    cp -r ${src_googletest_prometheus-cpp_recursive}/* $out/3rdparty/googletest
  '';

  src_protobuf = fetchFromGitHub {
    hash = "sha256-InCW/Sb4E7dQeg3VHgpCtm91qqfh0Qpmu4ZzKffacOQ=";
    owner = "protocolbuffers";
    repo = "protobuf";
    rev = "d1eca4e4b421cd2997495c4b4e65cea6be4e9b8a";
  };

  src_protobuf_recursive = runCommand "protobuf" { } ''
    cp -r ${src_protobuf} $out
    chmod u+w $out/third_party/benchmark
    cp -r ${src_benchmark_protobuf_recursive}/* $out/third_party/benchmark
    chmod u+w $out/third_party/googletest
    cp -r ${src_googletest_protobuf_recursive}/* $out/third_party/googletest
  '';

  src_psimd = fetchFromGitHub {
    hash = "sha256-lV+VZi2b4SQlRYrhKx9Dxc6HlDEFz3newvcBjTekupo=";
    owner = "Maratyszcza";
    repo = "psimd";
    rev = "072586a71b55b7f8c584153d223e95687148a900";
  };

  src_psimd_recursive = src_psimd;

  src_pthreadpool = fetchFromGitHub {
    hash = "sha256-R4YmNzWEELSkAws/ejmNVxqXDTJwcqjLU/o/HvgRn2E=";
    owner = "Maratyszcza";
    repo = "pthreadpool";
    rev = "4fe0e1e183925bf8cfa6aae24237e724a96479b8";
  };

  src_pthreadpool_recursive = src_pthreadpool;

  src_pybind11 = fetchFromGitHub {
    hash = "sha256-ZiwNGsE1FOkhnWv/1ib1akhQ4FZvrXRCDnnBZoPp6r4=";
    owner = "pybind";
    repo = "pybind11";
    rev = "f5fbe867d2d26e4a0a9177a51f6e568868ad3dc8";
  };

  src_pybind11_onnx = fetchFromGitHub {
    hash = "sha256-SNLdtrOjaC3lGHN9MAqTf51U9EzNKQLyTMNPe0GcdrU=";
    owner = "pybind";
    repo = "pybind11";
    rev = "a2e59f0e7065404b44dfe92a28aca47ba1378dc4";
  };

  src_pybind11_onnx_recursive = src_pybind11_onnx;
  src_pybind11_recursive = src_pybind11;

  src_pybind11_tensorpipe = fetchFromGitHub {
    hash = "sha256-3TALLHJAeWCSf88oBgLyyUoI/HyWGasAcAy4fGOQt04=";
    owner = "pybind";
    repo = "pybind11";
    rev = "a23996fce38ff6ccfbcdc09f1e63f2c4be5ea2ef";
  };

  src_pybind11_tensorpipe_recursive = runCommand "pybind11_tensorpipe" { } ''
    cp -r ${src_pybind11_tensorpipe} $out
    chmod u+w $out/tools/clang
    cp -r ${src_clang-cindex-python3_recursive}/* $out/tools/clang
  '';

  src_pytorch = fetchFromGitHub {
    hash = "sha256-IyQs9CQbbpZYpd+8YhIj/ULjsIWu6gjkGrGSeMWqKvw=";
    owner = "pytorch";
    repo = "pytorch";
    rev = "v2.12.0";
  };

  src_pytorch_recursive = runCommand "pytorch" { } ''
    cp -r ${src_pytorch} $out
    chmod u+w $out/android/libs/fbjni
    cp -r ${src_fbjni_recursive}/* $out/android/libs/fbjni
    chmod u+w $out/third_party/aiter
    cp -r ${src_aiter_recursive}/* $out/third_party/aiter
    chmod u+w $out/third_party/benchmark
    cp -r ${src_benchmark_recursive}/* $out/third_party/benchmark
    chmod u+w $out/third_party/composable_kernel
    cp -r ${src_composable_kernel_recursive}/* $out/third_party/composable_kernel
    chmod u+w $out/third_party/cpp-httplib
    cp -r ${src_cpp-httplib_recursive}/* $out/third_party/cpp-httplib
    chmod u+w $out/third_party/cpuinfo
    cp -r ${src_cpuinfo_recursive}/* $out/third_party/cpuinfo
    chmod u+w $out/third_party/cudnn_frontend
    cp -r ${src_cudnn-frontend_recursive}/* $out/third_party/cudnn_frontend
    chmod u+w $out/third_party/cutlass
    cp -r ${src_cutlass_recursive}/* $out/third_party/cutlass
    chmod u+w $out/third_party/fbgemm
    cp -r ${src_fbgemm_recursive}/* $out/third_party/fbgemm
    chmod u+w $out/third_party/flash-attention
    cp -r ${src_flash-attention_recursive}/* $out/third_party/flash-attention
    chmod u+w $out/third_party/flatbuffers
    cp -r ${src_flatbuffers_recursive}/* $out/third_party/flatbuffers
    chmod u+w $out/third_party/fmt
    cp -r ${src_fmt_recursive}/* $out/third_party/fmt
    chmod u+w $out/third_party/FP16
    cp -r ${src_FP16_recursive}/* $out/third_party/FP16
    chmod u+w $out/third_party/FXdiv
    cp -r ${src_FXdiv_recursive}/* $out/third_party/FXdiv
    chmod u+w $out/third_party/gemmlowp/gemmlowp
    cp -r ${src_gemmlowp_recursive}/* $out/third_party/gemmlowp/gemmlowp
    chmod u+w $out/third_party/gloo
    cp -r ${src_gloo_recursive}/* $out/third_party/gloo
    chmod u+w $out/third_party/googletest
    cp -r ${src_googletest_recursive}/* $out/third_party/googletest
    chmod u+w $out/third_party/ideep
    cp -r ${src_ideep_recursive}/* $out/third_party/ideep
    chmod u+w $out/third_party/ittapi
    cp -r ${src_ittapi_recursive}/* $out/third_party/ittapi
    chmod u+w $out/third_party/kineto
    cp -r ${src_kineto_recursive}/* $out/third_party/kineto
    chmod u+w $out/third_party/kleidiai
    cp -r ${src_kleidiai_recursive}/* $out/third_party/kleidiai
    chmod u+w $out/third_party/mimalloc
    cp -r ${src_mimalloc_recursive}/* $out/third_party/mimalloc
    chmod u+w $out/third_party/mslk
    cp -r ${src_MSLK_recursive}/* $out/third_party/mslk
    chmod u+w $out/third_party/nlohmann
    cp -r ${src_json_recursive}/* $out/third_party/nlohmann
    chmod u+w $out/third_party/NNPACK
    cp -r ${src_NNPACK_recursive}/* $out/third_party/NNPACK
    chmod u+w $out/third_party/NVTX
    cp -r ${src_NVTX_recursive}/* $out/third_party/NVTX
    chmod u+w $out/third_party/onnx
    cp -r ${src_onnx_recursive}/* $out/third_party/onnx
    chmod u+w $out/third_party/pocketfft
    cp -r ${src_pocketfft_recursive}/* $out/third_party/pocketfft
    chmod u+w $out/third_party/protobuf
    cp -r ${src_protobuf_recursive}/* $out/third_party/protobuf
    chmod u+w $out/third_party/psimd
    cp -r ${src_psimd_recursive}/* $out/third_party/psimd
    chmod u+w $out/third_party/pthreadpool
    cp -r ${src_pthreadpool_recursive}/* $out/third_party/pthreadpool
    chmod u+w $out/third_party/pybind11
    cp -r ${src_pybind11_recursive}/* $out/third_party/pybind11
    chmod u+w $out/third_party/python-peachpy
    cp -r ${src_PeachPy_recursive}/* $out/third_party/python-peachpy
    chmod u+w $out/third_party/sleef
    cp -r ${src_sleef_recursive}/* $out/third_party/sleef
    chmod u+w $out/third_party/tensorpipe
    cp -r ${src_tensorpipe_recursive}/* $out/third_party/tensorpipe
    chmod u+w $out/third_party/VulkanMemoryAllocator
    cp -r ${src_VulkanMemoryAllocator_recursive}/* $out/third_party/VulkanMemoryAllocator
    chmod u+w $out/third_party/XNNPACK
    cp -r ${src_XNNPACK_recursive}/* $out/third_party/XNNPACK
  '';

  src_sleef = fetchFromGitHub {
    hash = "sha256-bjT+F7/nyiB4f0T06/flbpIWFZbUxjf1TjWMe3112Ig=";
    owner = "shibatch";
    repo = "sleef";
    rev = "5a1d179df9cf652951b59010a2d2075372d67f68";
  };

  src_sleef_recursive = src_sleef;

  src_tensorpipe = fetchFromGitHub {
    hash = "sha256-ZidonG6q621rbdRrlW6ad7WdH0os81GNBBuPE5kQEsU=";
    owner = "pytorch";
    repo = "tensorpipe";
    rev = "2b4cd91092d335a697416b2a3cb398283246849d";
  };

  src_tensorpipe_recursive = runCommand "tensorpipe" { } ''
    cp -r ${src_tensorpipe} $out
    chmod u+w $out/third_party/googletest
    cp -r ${src_googletest_tensorpipe_recursive}/* $out/third_party/googletest
    chmod u+w $out/third_party/libnop
    cp -r ${src_libnop_recursive}/* $out/third_party/libnop
    chmod u+w $out/third_party/libuv
    cp -r ${src_libuv_recursive}/* $out/third_party/libuv
    chmod u+w $out/third_party/pybind11
    cp -r ${src_pybind11_tensorpipe_recursive}/* $out/third_party/pybind11
  '';
}
.src_pytorch_recursive
# Update using: unroll-src [version]
