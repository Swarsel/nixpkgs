{
  lib,
  extraPackages,
  makeBinaryWrapper,
  symlinkJoin,
  television,
}:

symlinkJoin {
  inherit (television) version;
  pname = "${television.pname}-with-pkgs";
  nativeBuildInputs = [ makeBinaryWrapper ];

  postBuild = ''
    wrapProgram $out/bin/tv \
      --prefix PATH : "${lib.makeBinPath extraPackages}"
  '';

  paths = [ television ];

  meta = {
    inherit (television.meta)
      description
      longDescription
      homepage
      changelog
      license
      mainProgram
      maintainers
      ;
  };
}
