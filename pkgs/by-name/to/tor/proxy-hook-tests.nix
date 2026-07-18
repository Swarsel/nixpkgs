{
  fetchurl,
  fetchFromGitLab,
  fetchgit,
  fetchzip,
  linkFarm,
  testers,
  tor,
}:
let
  domain = "eweiibe6tdjsdprb4px6rqrzzcsi22m4koia44kc5pcjr7nec2rlxyad.onion";
  rev = "933c5491db00c703d5d8264fdabd5a5b10aff96f";
  hash = "sha256-o6Wpso8GSlQH39GpH3IXZyrVhdP8pEYFxLDq9a7yHX0=";
in
linkFarm "tor-proxy-hook-tests" {
  fetchFromGitLab = testers.invalidateFetcherByDrvHash fetchFromGitLab {
    inherit domain rev hash;
    nativeBuildInputs = [ tor.proxyHook ];
    name = "gitlab-tor-source";
    owner = "tpo/core";
    protocol = "http";
    repo = "tor";
  };

  fetchgit = testers.invalidateFetcherByDrvHash fetchgit {
    inherit rev hash;
    nativeBuildInputs = [ tor.proxyHook ];
    name = "fetchgit-tor-source";
    url = "http://${domain}/tpo/core/tor";
  };

  fetchurl = testers.invalidateFetcherByDrvHash fetchurl {
    nativeBuildInputs = [ tor.proxyHook ];
    hash = "sha256-oX4WbsscLADgJ5o+czpueyAih7ic0u4lZQs7y1vMA3A=";
    name = "fetchurl-tor-source";
    url = "http://${domain}/tpo/core/tor/-/raw/${rev}/Cargo.lock";
  };

  fetchzip = testers.invalidateFetcherByDrvHash fetchzip {
    inherit hash;
    nativeBuildInputs = [ tor.proxyHook ];
    name = "fetchzip-tor-source";
    url = "http://${domain}/tpo/core/tor/-/archive/${rev}/tor-${rev}.zip";
  };
}
