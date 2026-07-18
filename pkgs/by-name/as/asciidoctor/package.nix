{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "asciidoctor";

  exes = [
    "asciidoctor"
    "asciidoctor-pdf"
  ];

  gemdir = ./.;

  passthru = {
    updateScript = bundlerUpdateScript "asciidoctor";
  };

  meta = {
    description = "Faster Asciidoc processor written in Ruby";
    homepage = "https://asciidoctor.org/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gpyh
      nicknovitski
    ];

    platforms = lib.platforms.unix;
  };
}
