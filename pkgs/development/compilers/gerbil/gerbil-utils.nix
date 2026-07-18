{ lib, fetchFromGitHub, ... }:

{
  pname = "gerbil-utils";
  version = "unstable-2023-12-06";
  gerbil-package = "clan";
  git-version = "0.4-13-g9398865";

  pre-src = {
    fun = fetchFromGitHub;
    owner = "mighty-gerbils";
    repo = "gerbil-utils";
    rev = "939886579508ff34b58a0d65bbb7d666125d0551";
    sha256 = "0dga03qq7iy12bnpxr6d40qhvihsvn3y87psf2w2clnpypjb3blx";
  };

  softwareName = "Gerbil-utils";
  version-path = "version";

  meta = {
    description = "Gerbil Clan: Community curated Collection of Common Utilities";
    homepage = "https://github.com/fare/gerbil-utils";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ fare ];
    platforms = lib.platforms.unix;
  };
}
