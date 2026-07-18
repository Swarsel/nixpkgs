{ stdenv, croc }:

stdenv.mkDerivation {
  nativeBuildInputs = [ croc ];
  __darwinAllowLocalNetworking = true;

  buildCommand = ''
    HOME="$(mktemp -d)"
    # start a local relay
    croc relay --ports 11111,11112 &

    export CROC_SECRET="sN3nx4hGLeihmn8G"

    # start sender in background
    MSG="See you later, alligator!"
    croc --relay localhost:11111 send --code correct-horse-battery-staple --text "$MSG" &

    # wait for things to settle
    sleep 1
    MSG2=$(croc --relay localhost:11111 --yes correct-horse-battery-staple)

    # compare
    [ "$MSG" = "$MSG2" ] && touch $out
  '';

  name = "croc-test-local-relay";

  meta = {
    broken = stdenv.hostPlatform.isDarwin;
    timeout = 300;
  };
}
