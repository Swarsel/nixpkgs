lib: self:

let
  inherit (lib) elemAt;

  matchForgeRepo = builtins.match "(.+)/(.+)";

  fetchers = lib.mapAttrs (_: fetcher: self.callPackage fetcher { }) {
    bitbucket =
      { fetchhg }:
      {
        repo ? null,
        ...
      }:
      { commit, sha256, ... }:
      fetchhg {
        inherit sha256;
        rev = commit;
        url = "https://bitbucket.com/${repo}";
      };

    codeberg =
      { fetchzip }:
      {
        repo ? null,
        ...
      }:
      { commit, sha256, ... }:
      fetchzip {
        inherit sha256;
        url = "https://codeberg.org/${repo}/archive/${commit}.tar.gz";
      };

    git = (
      { fetchgit }:
      {
        url ? null,
        ...
      }:
      { commit, sha256, ... }:
      (fetchgit {
        inherit sha256 url;
        rev = commit;
      }).overrideAttrs
        (_: {
          GIT_SSL_NO_VERIFY = true;
        })
    );

    github =
      { fetchFromGitHub }:
      {
        repo ? null,
        ...
      }:
      { commit, sha256, ... }:
      let
        m = matchForgeRepo repo;
      in
      assert m != null;
      fetchFromGitHub {
        inherit sha256;
        owner = elemAt m 0;
        repo = elemAt m 1;
        rev = commit;
      };

    gitlab =
      { fetchFromGitLab }:
      {
        repo ? null,
        ...
      }:
      { commit, sha256, ... }:
      let
        m = matchForgeRepo repo;
      in
      assert m != null;
      fetchFromGitLab {
        inherit sha256;
        owner = elemAt m 0;
        repo = elemAt m 1;
        rev = commit;
      };

    hg =
      { fetchhg }:
      {
        url ? null,
        ...
      }:
      { commit, sha256, ... }:
      fetchhg {
        inherit sha256 url;
        rev = commit;
      };

    sourcehut =
      { fetchzip }:
      {
        repo ? null,
        ...
      }:
      { commit, sha256, ... }:
      fetchzip {
        inherit sha256;
        url = "https://git.sr.ht/~${repo}/archive/${commit}.tar.gz";
      };
  };

in
{

  melpaDerivation =
    variant:
    {
      ename,
      fetcher,
      commit ? null,
      sha256 ? null,
      ...
    }@args:
    let
      sourceArgs = args.${variant};
      version = sourceArgs.version or null;
      deps = sourceArgs.deps or null;
      error = sourceArgs.error or args.error or null;
      hasSource = lib.hasAttr variant args;
      pname = builtins.replaceStrings [ "@" ] [ "at" ] ename;
      broken = error != null;
    in
    if hasSource then
      lib.nameValuePair ename (
        self.callPackage (
          { fetchurl, melpaBuild, ... }@pkgargs:
          melpaBuild {
            inherit pname ename;
            inherit (sourceArgs) commit;

            version = lib.optionalString (version != null) (
              lib.concatStringsSep "." (
                map toString
                  # Hack: Melpa archives contains versions with parse errors such as [ 4 4 -4 413 ] which should be 4.4-413
                  # This filter method is still technically wrong, but it's computationally cheap enough and tapers over the issue
                  (builtins.filter (n: n >= 0) version)
              )
            );

            # TODO: Broken should not result in src being null (hack to avoid eval errors)
            src = if (sha256 == null || broken) then null else fetchers.${fetcher} args sourceArgs;

            packageRequires = lib.optionals (deps != null) (
              map (dep: pkgargs.${dep} or self.${dep} or null) deps
            );

            recipe =
              if commit == null then
                null
              else
                fetchurl {
                  inherit sha256;
                  name = pname + "-recipe";
                  url = "https://raw.githubusercontent.com/melpa/melpa/${commit}/recipes/${ename}";
                };

            meta = (sourceArgs.meta or { }) // {
              inherit broken;
            };
          }
        ) { }
      )
    else
      null;

}
