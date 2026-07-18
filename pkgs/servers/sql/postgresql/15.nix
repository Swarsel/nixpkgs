{
  version = "15.18";
  hash = "sha256-tw1zzgLXx7Jr4bi8rMKRmTJzOSQFGvrP2nHr9FcVrjs=";

  muslPatches = {
    dont-use-locale-a = {
      hash = "sha256-fk+y/SvyA4Tt8OIvDl7rje5dLs3Zw+Ln1oddyYzerOo=";
      url = "https://git.alpinelinux.org/aports/plain/main/postgresql15/dont-use-locale-a-on-musl.patch?id=f424e934e6d076c4ae065ce45e734aa283eecb9c";
    };
  };

  rev = "refs/tags/REL_15_18";
}
