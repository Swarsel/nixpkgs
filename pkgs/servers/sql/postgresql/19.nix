{
  version = "19beta1";
  hash = "sha256-thvbttX8wwGLf5tMJRHl86Xv8OgINzahoqB/AzAdtMI=";

  muslPatches = {
    dont-use-locale-a = {
      hash = "sha256-6zjz3OpMx4qTETdezwZxSJPPdOvhCNu9nXvAaU9SwH8=";
      url = "https://git.alpinelinux.org/aports/plain/main/postgresql17/dont-use-locale-a-on-musl.patch?id=d69ead2c87230118ae7f72cef7d761e761e1f37e";
    };
  };

  rev = "refs/tags/REL_19_BETA1";
}
