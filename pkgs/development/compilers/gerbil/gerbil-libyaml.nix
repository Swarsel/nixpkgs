{
  lib,
  fetchFromGitHub,
  libyaml,
  pkgs,
  ...
}:

{
  pname = "gerbil-libyaml";
  version = "unstable-2023-09-23";
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ libyaml ];
  gerbil-package = "clan";
  gerbilInputs = [ ];
  git-version = "398a197";

  pre-src = {
    fun = fetchFromGitHub;
    owner = "mighty-gerbils";
    repo = "gerbil-libyaml";
    rev = "398a19782b1526de94b70de165c027d4b6029dac";
    sha256 = "0plmwx1i23c9nzzg6zxz2xi0y92la97mak9hg6h3c6d8kxvajb5c";
  };

  softwareName = "Gerbil-LibYAML";
  version-path = "";

  meta = {
    description = "libyaml bindings for Gerbil";
    homepage = "https://github.com/mighty-gerbils/gerbil-libyaml";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fare ];
    platforms = lib.platforms.unix;
  };
  # "-L${libyaml}/lib"
}
