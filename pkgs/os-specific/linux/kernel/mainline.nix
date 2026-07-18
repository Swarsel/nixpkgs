let
  allKernels = builtins.fromJSON (builtins.readFile ./kernels-org.json);
in

{
  lib,
  fetchurl,
  branch,
  buildLinux,
  fetchzip,
  ...
}@args:

let
  thisKernel = allKernels.${branch};
  inherit (thisKernel) version;

  src =
    # testing kernels are a special case because they don't have tarballs on the CDN
    if branch == "testing" then
      fetchzip {
        inherit (thisKernel) hash;
        url = "https://git.kernel.org/torvalds/t/linux-${version}.tar.gz";
      }
    else
      fetchurl {
        inherit (thisKernel) hash;
        url = "mirror://kernel/linux/kernel/v${lib.versions.major version}.x/linux-${version}.tar.xz";
      };

  args' =
    (removeAttrs args [ "branch" ])
    // {
      inherit src version;
      extraMeta.branch = branch;
      isLTS = thisKernel.lts;
      modDirVersion = lib.versions.pad 3 version;
    }
    // (args.argsOverride or { });
in
buildLinux args'
