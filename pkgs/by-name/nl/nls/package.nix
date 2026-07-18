{
  nickel,
  symlinkJoin,
}:

symlinkJoin {
  inherit (nickel) version;
  pname = "nls";
  name = "nls-${nickel.version}";
  paths = [ nickel.nls ];

  meta = {
    inherit (nickel.meta)
      homepage
      changelog
      license
      maintainers
      ;

    description = "Language server for the Nickel programming language";

    longDescription = ''
      The Nickel Language Server (NLS) is a language server for the Nickel
      programming language. NLS offers error messages, type hints, and
      auto-completion right in your favorite LSP-enabled editor.
    '';

    mainProgram = "nls";
  };
}
