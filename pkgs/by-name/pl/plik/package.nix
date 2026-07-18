{
  buildGoModule,
  plikd,
}:

buildGoModule (finalAttrs: {
  inherit (plikd)
    version
    src
    postPatch
    passthru
    ;

  pname = "plik";
  vendorHash = null;

  postInstall = ''
    mv $out/bin/client $out/bin/plik
  '';

  subPackages = [ "client" ];

  meta = {
    inherit (plikd.meta)
      description
      homepage
      license
      maintainers
      ;

    mainProgram = "plik";
  };
})
