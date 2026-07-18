{
  mkAppleDerivation,
  sourceRelease,
  stdenvNoCC,
}:

let
  iokitUser = sourceRelease "IOKitUser";

  privateHeaders = stdenvNoCC.mkDerivation {
    buildCommand = ''
      install -D -t "$out/include/IOKit/pwr_mgt" \
        '${iokitUser}/pwr_mgt.subproj/IOPMLibPrivate.h' \
        '${iokitUser}/pwr_mgt.subproj/IOPMAssertionCategories.h'
    '';

    name = "file_cmds-deps-private-headers";
  };
in
mkAppleDerivation {
  env.NIX_CFLAGS_COMPILE = "-I${privateHeaders}/include";
  releaseName = "PowerManagement";
  xcodeHash = "sha256-8dASJnzc7yZ4LNbanNjWuCoJunxAz/7R1Ulj/zOrkkI=";
  meta.description = "Contains the Darwin caffeinate command";
}
