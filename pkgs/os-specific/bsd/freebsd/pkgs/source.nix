{ fetchFromGitHub, sourceData }:

# Using fetchFromGitHub from their mirror because we cannot use git during bootstrap
# If you want you could fetchurl from "https://cgit.FreeBSD.org/src" instead.
# The update script still pulls directly from git.freebsd.org
# Note that hashes with `forceFetchGit = true` may be different due to `export-ignore`
# directives in gitattributes files.
fetchFromGitHub {
  inherit (sourceData) rev hash;
  owner = "freebsd";
  repo = "freebsd-src";
}
