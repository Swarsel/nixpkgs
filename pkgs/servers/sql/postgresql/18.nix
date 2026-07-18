{
  version = "18.4";
  hash = "sha256-Ac/Dqcj8vjcW3my5vsnKaMiQqTq/HPtUzckJ3SMyrfA=";

  muslPatches = {
    dont-use-locale-a = {
      hash = "sha256-6zjz3OpMx4qTETdezwZxSJPPdOvhCNu9nXvAaU9SwH8=";
      url = "https://git.alpinelinux.org/aports/plain/main/postgresql17/dont-use-locale-a-on-musl.patch?id=d69ead2c87230118ae7f72cef7d761e761e1f37e";
    };
  };

  rev = "refs/tags/REL_18_4";
}
