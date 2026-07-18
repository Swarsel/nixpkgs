{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "pru";
  exes = [ "pru" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "pru";

  meta = {
    description = "Pipeable Ruby";

    longDescription = ''
      pru allows to use Ruby scripts as filters, working as a convenient,
      higher-level replacement of typical text processing tools (like sed, awk,
      grep etc.).
    '';

    homepage = "https://github.com/grosser/pru";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
