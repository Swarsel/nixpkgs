{ callPackage, requireFile }:

callPackage ./runtime-build.nix rec {
  version = "21.0.559";

  src = requireFile {
    url = "https://www.sidefx.com/download/daily-builds/?production=true";
    hash = "sha256-bZmoH1NKQhhMAhIl3pTL7irUZ7HrOhS8R7GApLD5514=";
    name = "houdini-${version}-linux_x86_64_gcc11.2.tar.gz";
  };

  eulaDate = "2021-10-13";
  outputHash = "sha256-/7ctlMUoyJdPdBQV7rRO9pWcg9bXcnMJsB9TN/Jo8QQ=";
}
