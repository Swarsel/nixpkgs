{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

let
  version = "0.0.2";
in
buildGoModule {
  inherit version;
  pname = "archimede";

  src = fetchFromGitHub {
    owner = "gennaro-tedesco";
    repo = "archimede";
    tag = "v${version}";
    hash = "sha256-7P7PtzYlcNYG2+KW9zvcaRlTW+vHw8jeLD2dEQXmrzc=";
  };

  vendorHash = "sha256-F74TVp6+UdV31YVYYHWtdIzpbbiYM2I8csGobesFN2g=";

  meta = {
    description = "Unobtrusive directory information fetcher";
    homepage = "https://github.com/gennaro-tedesco/archimede";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.anugrahn1 ];
    mainProgram = "archimede";
  };
}
