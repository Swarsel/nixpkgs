{
  lib,
  mkDerivation,
}:

mkDerivation {
  outputs = [
    "out"
    "man"
  ];

  extraPaths = [
    "gnu/llvm/libunwind"
    "gnu/llvm/libcxx"
    "gnu/lib/libcxx"
  ];

  libcMinimal = true;
  path = "gnu/lib/libexecinfo";
  meta.platforms = lib.platforms.openbsd;
}
