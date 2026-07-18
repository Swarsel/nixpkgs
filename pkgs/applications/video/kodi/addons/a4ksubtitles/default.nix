{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
  requests,
  vfs-libarchive,
}:

buildKodiAddon rec {
  pname = "a4ksubtitles";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "a4k-openproject";
    repo = "a4kSubtitles";
    rev = "${namespace}/${namespace}-${version}";
    sha256 = "sha256-t6oclFAOsUC+hFtw6wjRh1zl2vQfc7RKblVJpBPfE9w=";
  };

  propagatedBuildInputs = [
    requests
    vfs-libarchive
  ];

  namespace = "service.subtitles.a4ksubtitles";

  meta = {
    description = "Multi-Source Subtitles Addon";
    homepage = "https://a4k-openproject.github.io/a4kSubtitles/";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
