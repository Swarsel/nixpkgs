{
  lib,
  fetchgit,
  fetchhg,
  fetchzip,
  repoRevToNameMaybe,
}:

let
  inherit (lib)
    assertOneOf
    makeOverridable
    optionalString
    ;
in

makeOverridable (
  {
    owner,
    repo,
    domain ? "sr.ht",
    fetchSubmodules ? false,
    name ? repoRevToNameMaybe repo (lib.revOrTag rev tag) "sourcehut",
    rev ? null,
    tag ? null,
    vc ? "git",
    ... # For hash agility
  }@args:

  assert (
    lib.xor (tag == null) (rev == null)
    || throw "fetchFromSourcehut requires one of either `rev` or `tag` to be provided (not both)."
  );

  assert (
    assertOneOf "vc" vc [
      "hg"
      "git"
    ]
  );

  let
    urlFor = resource: "https://${resource}.${domain}/${owner}/${repo}";
    rev' = if tag != null then tag else rev;
    baseUrl = urlFor vc;
    baseArgs = {
      inherit name;
    }
    // removeAttrs args [
      "owner"
      "repo"
      "rev"
      "tag"
      "domain"
      "vc"
      "name"
      "fetchSubmodules"
    ];
    vcArgs = baseArgs // {
      rev = rev';
      url = baseUrl;
    };
    fetcher = if fetchSubmodules then vc else "zip";
    cases = {
      git = {
        arguments = vcArgs // {
          fetchSubmodules = true;
        };

        fetch = fetchgit;
      };

      hg = {
        arguments = vcArgs // {
          fetchSubrepos = true;
        };

        fetch = fetchhg;
      };

      zip = {
        arguments = baseArgs // {
          postFetch = optionalString (vc == "hg") ''
            rm -f "$out/.hg_archival.txt"
          ''; # impure file; see #12002

          url = "${baseUrl}/archive/${rev'}.tar.gz";

          passthru = (args.passthru or { }) // {
            gitRepoUrl = urlFor "git";
          };
        };

        fetch = fetchzip;
      };
    };
  in
  cases.${fetcher}.fetch cases.${fetcher}.arguments
  // {
    inherit tag;
    rev = rev';
    meta.homepage = "${baseUrl}";
  }
)
