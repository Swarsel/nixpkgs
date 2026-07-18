{
  lib,
  fetchurl ? null,
  fetchgit ? null,
  gitRelease ? null,
  monorepoSrc' ? null,
  officialRelease ? null,
  release_version ? null,
  version ? null,
}@args:

rec {
  gcc_meta = {
    license = with lib.licenses; [ gpl3Plus ];
    teams = [ lib.teams.gcc ];
  };

  monorepoSrc =
    if monorepoSrc' != null then
      monorepoSrc'
    else if gitRelease != null then
      fetchgit {
        inherit (gitRelease) rev;
        hash = releaseInfo.original.sha256;
        url = "https://gcc.gnu.org/git/gcc.git";
      }
    else
      fetchurl {
        hash = releaseInfo.original.sha256;
        url = "mirror://gcc/releases/gcc-${releaseInfo.version}/gcc-${releaseInfo.version}.tar.xz";
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
