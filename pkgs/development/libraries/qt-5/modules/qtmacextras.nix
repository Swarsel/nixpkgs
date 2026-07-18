{
  lib,
  llvmPackages,
  qtModule,
  qtbase,
}:

qtModule {
  pname = "qtmacextras";
  # TODO: Remove once #536365 reaches this branch
  nativeBuildInputs = [ llvmPackages.lld ];
  propagatedBuildInputs = [ qtbase ];
  env.NIX_CFLAGS_LINK = "-fuse-ld=lld";

  meta = {
    maintainers = [ ];
    platforms = lib.platforms.darwin;
  };
}
