{
  lib,
  fetchgit,
  fetchzip,
}:

lib.makeOverridable (
  {
    owner,
    repo,
    rev,
    deepClone ? false,
    domain ? "git.9front.org",
    leaveDotGit ? false,
    name ? "source",
    ... # For hash agility
  }@args:

  let
    passthruAttrs = removeAttrs args [
      "domain"
      "owner"
      "repo"
      "rev"
      "leaveDotGit"
      "deepClone"
    ];

    useFetchGit = leaveDotGit || deepClone;
    fetcher = if useFetchGit then fetchgit else fetchzip;

    gitRepoUrl = "git://${domain}/${owner}/${repo}";

    fetcherArgs =
      (
        if useFetchGit then
          {
            # git9 does not support shallow fetches
            inherit rev leaveDotGit;
            url = gitRepoUrl;
          }
        else
          {
            url = "https://${domain}/${owner}/${repo}/${rev}/snap.tar.gz";

            passthru = {
              inherit gitRepoUrl;
            };
          }
      )
      // passthruAttrs
      // {
        inherit name;
      };
  in

  fetcher fetcherArgs // { inherit rev; }
)
