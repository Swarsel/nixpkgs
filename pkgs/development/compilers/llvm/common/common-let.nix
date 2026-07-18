{
  lib,
  fetchFromGitHub ? null,
  gitRelease ? null,
  monorepoSrc' ? null,
  officialRelease ? null,
  release_version ? null,
  version ? null,
}@args:

rec {
  llvm_meta = {
    identifiers.cpeParts.vendor = "llvm";

    license =
      with lib.licenses;
      # Contributions after June 1st, 2024 are only licensed under asl20 and
      # llvm-exception: https://github.com/llvm/llvm-project/pull/92394
      if lib.versionAtLeast release_version "19" then
        AND [
          ncsa
          (WITH asl20 llvm-exception)
        ]
      else
        ncsa;

    # See llvm/cmake/config-ix.cmake.
    platforms =
      lib.platforms.aarch64
      ++ lib.platforms.arm
      ++ lib.platforms.mips
      ++ lib.platforms.power
      ++ lib.platforms.s390x
      ++ lib.platforms.wasi
      ++ lib.platforms.x86
      ++ lib.platforms.riscv
      ++ lib.platforms.m68k
      ++ lib.platforms.loongarch64;

    teams = [
      lib.teams.llvm
      lib.teams.security-review
    ];
  };

  monorepoSrc =
    if monorepoSrc' != null then
      monorepoSrc'
    else
      let
        sha256 = releaseInfo.original.sha256;
        rev = if gitRelease != null then gitRelease.rev else "llvmorg-${releaseInfo.version}";
      in
      fetchFromGitHub rec {
        inherit rev sha256;
        owner = "llvm";
        repo = "llvm-project";
        passthru = { inherit owner repo rev; };
      };

  releaseInfo =
    if gitRelease != null then
      rec {
        version = gitRelease.rev-version;
        original = gitRelease;
        release_version = args.version or original.version;
      }
    else
      rec {
        version =
          if original ? candidate then "${release_version}-${original.candidate}" else release_version;

        original = officialRelease;
        release_version = args.version or original.version;
      };

}
