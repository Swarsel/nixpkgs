{
  lib,
  stdenv,
  boost179,
  callPackage,
  config,
  newScope,
  opencv,
  openmpi,
  pkgs,
  python3Packages,
}:

let
  outer = lib.makeScope newScope (
    self:
    let
      inherit (self) llvm;
      origStdenv = stdenv;
      pyPackages = python3Packages;
      openmpi-orig = openmpi;
      rocmClangStdenv = llvm.rocmClangStdenv;
    in
    {
      inherit rocmClangStdenv;
      inherit (self.llvm) rocm-toolchain clang openmp;

      amdsmi = pyPackages.callPackage ./amdsmi {
        inherit (self) rocmUpdateScript;
      };

      aotriton = self.callPackage ./aotriton { stdenv = origStdenv; };
      aqlprofile = self.callPackage ./aqlprofile { };

      ck4inductor = pyPackages.callPackage ./composable_kernel/ck4inductor.nix {
        inherit (self) composable_kernel rocm-toolchain;
      };

      # Replaces hip, opencl-runtime, and rocclr
      clr = self.callPackage ./clr { };
      composable_kernel = self.callPackage ./composable_kernel { };
      # hipTensor - Only supports GFX9
      composable_kernel_base = self.callPackage ./composable_kernel/base.nix { };
      half = self.callPackage ./half { };
      hip-common = self.callPackage ./hip-common { };
      hipblas = self.callPackage ./hipblas { };
      hipblas-common = self.callPackage ./hipblas-common { };
      hipblaslt = self.callPackage ./hipblaslt { };
      hipcc = self.callPackage ./hipcc { stdenv = origStdenv; };
      hipcub = self.callPackage ./hipcub { };
      hipfft = self.callPackage ./hipfft { };
      hipfort = self.callPackage ./hipfort { };

      hipify = self.callPackage ./hipify {
        stdenv = origStdenv;
      };

      hiprand = self.callPackage ./hiprand { };
      hiprt = self.callPackage ./hiprt { };
      hipsolver = self.callPackage ./hipsolver { };
      hipsparse = self.callPackage ./hipsparse { };
      hipsparselt = self.callPackage ./hipsparselt { };
      # hsakmt was merged into rocm-runtime
      hsakmt = self.rocm-runtime;

      ## ROCm ##
      llvm = lib.recurseIntoAttrs (
        callPackage ./llvm/default.nix {
          # rocm-device-libs is used for .src only
          # otherwise would cause infinite recursion
          inherit (self) rocm-device-libs;
        }
      );

      migraphx = self.callPackage ./migraphx { stdenv = origStdenv; };

      miopen = self.callPackage ./miopen {
        boost = boost179.override { enableStatic = true; };
      };

      miopen-hip = self.miopen;

      mivisionx = self.callPackage ./mivisionx {
        opencv = opencv.override { enablePython = true; };
        stdenv = origStdenv;
      };

      mivisionx-cpu = self.mivisionx.override {
        rpp = self.rpp-cpu;
        useCPU = true;
        useOpenCL = false;
      };

      mivisionx-hip = self.mivisionx.override {
        rpp = self.rpp-hip;
        useCPU = false;
        useOpenCL = false;
      };

      mpi = self.openmpi;
      mscclpp = self.callPackage ./mscclpp { };

      # Even if config.rocmSupport is false we need rocmSupport true
      # version of ucc/ucx in openmpi in this package set
      openmpi = openmpi-orig.override (
        prev:
        let
          ucx = prev.ucx.override {
            enableCuda = false;
            enableRocm = true;
            rocmPackages = self;
          };
        in
        {
          inherit ucx;

          ucc = prev.ucc.override {
            inherit ucx;
            enableCuda = false;
          };
        }
      );

      rccl = self.callPackage ./rccl { };
      rdc = self.callPackage ./rdc { };
      rocalution = self.callPackage ./rocalution { };
      rocblas = self.callPackage ./rocblas { };
      rocdbgapi = self.callPackage ./rocdbgapi { };
      rocfft = self.callPackage ./rocfft { };
      rocgdb = self.callPackage ./rocgdb { };

      rocm-bandwidth-test = self.callPackage ./rocm-bandwidth-test {
        rocmPackages = self;
      };

      rocm-cmake = self.callPackage ./rocm-cmake { stdenv = origStdenv; };
      rocm-comgr = self.callPackage ./rocm-comgr { };
      rocm-core = self.callPackage ./rocm-core { stdenv = origStdenv; };
      rocm-device-libs = self.callPackage ./rocm-device-libs { };
      rocm-docs-core = python3Packages.callPackage ./rocm-docs-core { };

      rocm-runtime = self.callPackage ./rocm-runtime {
        stdenv = origStdenv;
      };

      rocm-smi = pyPackages.callPackage ./rocm-smi {
        inherit (self) rocmUpdateScript;
      };

      rocm-tests = self.callPackage ./rocm-tests {
        rocmPackages = self;
      };

      rocmUpdateScript = self.callPackage ./update.nix { };
      rocminfo = self.callPackage ./rocminfo { stdenv = origStdenv; };
      rocmlir = self.rocmlir-rock;

      rocmlir-rock = self.callPackage ./rocmlir {
        buildRockCompiler = true;
      };

      rocprim = self.callPackage ./rocprim { };
      rocprof-compute-viewer = self.callPackage ./rocprof-compute-viewer { };
      rocprof-trace-decoder = self.callPackage ./rocprof-trace-decoder { };

      rocprofiler = self.callPackage ./rocprofiler {
        inherit (llvm) clang;
      };

      rocprofiler-register = self.callPackage ./rocprofiler-register {
        inherit (llvm) clang;
      };

      rocprofiler-sdk = self.callPackage ./rocprofiler-sdk { };
      rocr-debug-agent = self.callPackage ./rocr-debug-agent { };
      rocrand = self.callPackage ./rocrand { };
      rocshmem = self.callPackage ./rocshmem { };
      rocsolver = self.callPackage ./rocsolver { };
      rocsparse = self.callPackage ./rocsparse { };
      rocthrust = self.callPackage ./rocthrust { };
      roctracer = self.callPackage ./roctracer { };
      rocwmma = self.callPackage ./rocwmma { };
      rpp = self.callPackage ./rpp { };
      rpp-cpu = self.rpp.override { useCPU = true; };
      rpp-hip = self.rpp.override { useCPU = false; };
      stdenv = rocmClangStdenv;

      tensile = pyPackages.callPackage ./tensile {
        inherit (self)
          rocmUpdateScript
          clr
          ;
      };

      meta = {
        # eval all pkgsRocm release attrs with
        # nix-eval-jobs --force-recurse pkgs/top-level/release.nix -I . --select "p: p.pkgsRocm" --no-instantiate
        release-packagePlatforms =
          let
            platforms = [
              "x86_64-linux"
            ];
            attrPaths = (builtins.fromJSON (builtins.readFile ./release-attrPaths.json)).attrPaths;
          in
          lib.foldl' (
            acc: path:
            if lib.hasAttrByPath (lib.splitString "." path) pkgs then
              lib.recursiveUpdate acc (lib.setAttrByPath (lib.splitString "." path) platforms)
            else
              acc
          ) { } attrPaths;
      };
    }
    // lib.optionalAttrs config.allowAliases {
      clang-ocl = throw ''
        'clang-ocl' has been deprecated upstream. Use ROCm's clang directly.
      ''; # Added 2025-3-16

      hsa-amd-aqlprofile-bin = lib.warn ''
        'hsa-amd-aqlprofile-bin' has been replaced by 'aqlprofile'.
      '' self.aqlprofile; # Added 2025-08-27

      miopen-opencl = throw ''
        'miopen-opencl' has been deprecated.
      ''; # Added 2024-3-3

      miopengemm = throw ''
        'miopengemm' has been deprecated.
      ''; # Added 2024-3-3

      mivisionx-opencl = throw ''
        'mivisionx-opencl' has been deprecated.
        Other versions of mivisionx are still available.
      ''; # Added 2024-3-24

      rocm-merged-llvm = throw ''
        'rocm-merged-llvm' has been removed.
        For 'libllvm' or 'libclang' use 'rocmPackages.llvm.libllvm/clang'.
        For a ROCm compiler toolchain use 'rocmPackages.rocm-toolchain'.
        If a package uses '$<TARGET_FILE:clang>' in CMake from 'libclang'
        it may be necessary to convince it to use 'rocm-toolchain' instead.
        'rocm-merged-llvm' avoided this at the cost of significantly bloating closure
        size.
      ''; # Added 2025-09-30

      rocm-thunk = throw ''
        'rocm-thunk' has been removed. It's now part of the ROCm runtime.
      ''; # Added 2025-3-16

      rocmPath = throw ''
        'rocm-path' has been removed. If a ROCM_PATH value is required in nixpkgs please
        construct one with the minimal set of required deps.
        For convenience use outside of nixpkgs consider one of the entries in
        'rocmPackages.meta'.
      ''; # Added 2025-09-30

      rpp-opencl = throw ''
        'rpp-opencl' has been removed as it has been broken for a year and has no consuming packages.
        Use 'rpp' or 'rpp-cpu' instead.
      ''; # Added 2026-03-08

      triton = throw ''
        'rocmPackages.triton' has been removed. Please use python3Packages.triton
      ''; # Added 2025-08-24
    }
  );
  scopeForArches =
    arches:
    outer.overrideScope (
      _final: prev: {
        clr = prev.clr.override {
          localGpuTargets = arches;
        };
      }
    );
in
outer
// builtins.listToAttrs (
  map (arch: {
    name = arch;
    value = scopeForArches [ arch ];
  }) outer.clr.gpuTargets
)
// {
  gfx10 = scopeForArches [
    "gfx1010"
    "gfx1030"
  ];

  gfx11 = scopeForArches [
    "gfx1100"
    "gfx1101"
    "gfx1102"
    "gfx1150"
    "gfx1151"
  ];

  gfx12 = scopeForArches [
    "gfx1200"
    "gfx1201"
  ];

  gfx9 = scopeForArches [
    "gfx906"
    "gfx908"
    "gfx90a"
    "gfx942"
  ];
}
