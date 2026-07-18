{
  TestPod,
  buildPerlModule,
  remctl,
}:

buildPerlModule {
  inherit (remctl) meta src version;
  pname = "NetRemctl";

  postPatch = ''
    cp -R tests/tap/perl/Test perl/t/lib
    rm perl/t/backend/options.t
    cd perl
  '';

  buildInputs = [ remctl ];
  checkInputs = [ TestPod ];
}
