{
  lib,
  stdenv,
  fetchFromSourcehut,
  port ? "1234",
}:

stdenv.mkDerivation {
  pname = "among-sus-unstable";
  version = "2021-05-19";

  src = fetchFromSourcehut {
    owner = "~martijnbraam";
    repo = "among-sus";
    rev = "554e60bf52e3fa931661b9414189a92bb8f69d78";
    sha256 = "0j1158nczhvy5i1ykvzvhlv4ndhibgng0dq1lw2bmi8q6k1q1s0w";
  };

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 among-sus $out/bin
  '';

  patchPhase = ''
    sed -i 's/port = 1234/port = ${port}/g' main.c
  '';

  meta = {
    description = "Among us, but it's a text adventure";
    homepage = "https://git.sr.ht/~martijnbraam/among-sus";
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.eyjhb ];
    platforms = lib.platforms.unix;
    mainProgram = "among-sus";
  };
}
