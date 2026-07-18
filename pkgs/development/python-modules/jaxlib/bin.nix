# For the moment we only support the CPU and GPU backends of jaxlib. The TPU
# backend will require some additional work. Those wheels are located here:
# https://storage.googleapis.com/jax-releases/libtpu_releases.html.

# See `python3Packages.jax.passthru` for CUDA tests.

{
  lib,
  stdenv,
  absl-py,
  autoPatchelfHook,
  buildPythonPackage,
  fetchPypi,
  flatbuffers,
  ml-dtypes,
  python,
  scipy,
}:

let
  version = "0.10.2";
  inherit (python) pythonVersion;

  # As of 2023-06-06, google/jax upstream is no longer publishing CPU-only wheels to their GCS bucket. Instead the
  # official instructions recommend installing CPU-only versions via PyPI.
  srcs =
    let
      getSrcFromPypi =
        {
          dist,
          hash,
          platform,
        }:
        fetchPypi {
          inherit
            version
            platform
            dist
            hash
            ;

          pname = "jaxlib";
          abi = dist;
          format = "wheel";
          # See the `disabled` attr comment below.
          python = dist;
        };
    in
    {
      "3.11-aarch64-darwin" = getSrcFromPypi {
        dist = "cp311";
        hash = "sha256-WpiHP8hnYjuB8r7hXVVLjt1liKGD0B+lDSGx49uW/ys=";
        platform = "macosx_11_0_arm64";
      };

      "3.11-aarch64-linux" = getSrcFromPypi {
        dist = "cp311";
        hash = "sha256-1EVl3P0bT2D3bZEcZRIRiopPx2S975JmP+y4v8zVTyM=";
        platform = "manylinux_2_27_aarch64";
      };

      "3.11-x86_64-linux" = getSrcFromPypi {
        dist = "cp311";
        hash = "sha256-H6yjxdRmLLSmEwpoEF1ou1IHZIF+Fl1u6/1nhsDR8w8=";
        platform = "manylinux_2_27_x86_64";
      };

      "3.12-aarch64-darwin" = getSrcFromPypi {
        dist = "cp312";
        hash = "sha256-R7t8ARUV6oYr5+gxP0D5xWy+wJ3Jig/LUBZ4X81FTAE=";
        platform = "macosx_11_0_arm64";
      };

      "3.12-aarch64-linux" = getSrcFromPypi {
        dist = "cp312";
        hash = "sha256-U7cpd65YLAOp6OHN7h77+OvBQYJwllsOaereV6z0AzE=";
        platform = "manylinux_2_27_aarch64";
      };

      "3.12-x86_64-linux" = getSrcFromPypi {
        dist = "cp312";
        hash = "sha256-/ojsRDcUxDeZaLbBCfn6YXx60ZuAKCjk17+GHNZtpLc=";
        platform = "manylinux_2_27_x86_64";
      };

      "3.13-aarch64-darwin" = getSrcFromPypi {
        dist = "cp313";
        hash = "sha256-TfUwr6NUoi3BdHpdVgZARQy7iV1JiJM4o/WMdqTHbI4=";
        platform = "macosx_11_0_arm64";
      };

      "3.13-aarch64-linux" = getSrcFromPypi {
        dist = "cp313";
        hash = "sha256-RbKLAjhperdLvPIEEar7bbQqzDGDbML9cR5c8Fa/lVY=";
        platform = "manylinux_2_27_aarch64";
      };

      "3.13-x86_64-linux" = getSrcFromPypi {
        dist = "cp313";
        hash = "sha256-nkgYtKh1b9ORh2bKKqU0ISWAn08Ipv5GAm1DhufCNkQ=";
        platform = "manylinux_2_27_x86_64";
      };

      "3.14-aarch64-darwin" = getSrcFromPypi {
        dist = "cp314";
        hash = "sha256-cuuiixL+4CYW+kKqS4gbSrYtd1fHhDxGJAHT+zSie+Q=";
        platform = "macosx_11_0_arm64";
      };

      "3.14-aarch64-linux" = getSrcFromPypi {
        dist = "cp314";
        hash = "sha256-8Y9W/ukGmc+6m2YnBFp6KZcCyw4q+CzhgNmmp8gEgJM=";
        platform = "manylinux_2_27_aarch64";
      };

      "3.14-x86_64-linux" = getSrcFromPypi {
        dist = "cp314";
        hash = "sha256-yjTzYxl/sKxAglgsp1UAeRA2njP4qLo9Ne2UtxBwEH0=";
        platform = "manylinux_2_27_x86_64";
      };
    };
in
buildPythonPackage {
  inherit version;
  pname = "jaxlib";

  # See https://discourse.nixos.org/t/ofborg-does-not-respect-meta-platforms/27019/6.
  src = (
    srcs."${pythonVersion}-${stdenv.hostPlatform.system}"
      or (throw "jaxlib-bin is not supported on ${stdenv.hostPlatform.system}")
  );

  # Prebuilt wheels are dynamically linked against things that nix can't find.
  # Run `autoPatchelfHook` to automagically fix them.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  # Dynamic link dependencies
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];
  __structuredAttrs = true;

  dependencies = [
    absl-py
    flatbuffers
    ml-dtypes
    scipy
  ];

  format = "wheel";
  pythonImportsCheck = [ "jaxlib" ];

  meta = {
    description = "Prebuilt jaxlib backend from PyPi";
    homepage = "https://github.com/google/jax";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ samuela ];
  };
}
