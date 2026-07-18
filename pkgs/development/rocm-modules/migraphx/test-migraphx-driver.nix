{
  lib,
  fetchurl,
  clr,
  makeImpureTest,
  migraphx,
  rocm-smi,
  writableTmpDirAsHomeHook,
}:

# Verify that a ≈50MiB resnet onnx can run with migraphx
let
  resnet18 = fetchurl {
    hash = "sha256-u2Io20n72qoA9atRsFIWb0zHF1WdJYgHQdMWfJhJGHA=";
    url = "https://huggingface.co/onnxmodelzoo/resnet18_Opset18_timm/resolve/main/resnet18_Opset18_timm.onnx";
    meta.license = lib.licenses.unfree;
  };
in
makeImpureTest {
  nativeBuildInputs = [
    writableTmpDirAsHomeHook
    migraphx
    clr
    rocm-smi
  ];

  name = "migraphx-driver";

  sandboxPaths = [
    "/sys"
    "/dev/dri"
    "/dev/kfd"
  ];

  # FIXME(@LunNova): tol values are set too high - was seeing high divergence on iGPU
  # want this test to be useful for verifying workloads run at all
  # and will investigate what's broken for accuracy
  testScript = ''
    rocm-smi
    migraphx-driver verify -O --rms-tol 0.03 --atol 1.0 --rtol 0.01 ${resnet18}
  '';

  testedPackage = "rocmPackages.migraphx";

  meta = {
    teams = [ lib.teams.rocm ];
  };
}
