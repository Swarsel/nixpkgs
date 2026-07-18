{
  itgmaniaPackages,
  makeWrapper,
  symlinkJoin,
  extraPackages ? [ ],
}:
let
  unwrapped = itgmaniaPackages.itgmania-unwrapped;
in
symlinkJoin {
  inherit (unwrapped) pname version meta;
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    makeWrapper $out/itgmania/itgmania $out/bin/itgmania \
      --chdir $out/itgmania
  '';

  paths = [ unwrapped ] ++ extraPackages;
  passthru.unwrapped = unwrapped;
}
