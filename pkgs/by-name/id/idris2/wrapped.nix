{
  lib,
  base,
  contrib,
  idris2-unwrapped,
  linear,
  makeBinaryWrapper,
  network,
  prelude,
  symlinkJoin,
  test,
  extraPackages ? [ ],
}:
let
  preludeLibs = [
    prelude
    linear
    base
    network
    contrib
    test
  ];
  supportLibrariesPath = lib.makeLibraryPath [ idris2-unwrapped.libidris2_support ];
  supportSharePath = lib.makeSearchPath "share" [ idris2-unwrapped.libidris2_support ];
  packagePath = lib.makeSearchPath "idris2-${idris2-unwrapped.version}" (
    preludeLibs ++ extraPackages
  );
in
symlinkJoin {
  inherit (idris2-unwrapped) version;
  pname = "idris2-wrapped";
  nativeBuildInputs = [ makeBinaryWrapper ];

  postBuild = ''
    wrapProgram "$out/bin/idris2" \
      --set CHEZ "${lib.getExe idris2-unwrapped.chez}" \
      --suffix IDRIS2_LIBS ':' "${supportLibrariesPath}" \
      --suffix IDRIS2_DATA ':' "${supportSharePath}" \
      --suffix IDRIS2_PACKAGE_PATH ':' ${packagePath} \
      --suffix LD_LIBRARY_PATH ':' "${supportLibrariesPath}" \
      --suffix DYLD_LIBRARY_PATH ':' "${supportLibrariesPath}"
  '';

  paths = [ idris2-unwrapped ];

  passthru = {
    src = idris2-unwrapped.src;
    prelude = preludeLibs;
    unwrapped = idris2-unwrapped;
  }
  // idris2-unwrapped.passthru;

  meta = {
    # Manually inherit so that pos works
    inherit (idris2-unwrapped.meta)
      description
      mainProgram
      homepage
      changelog
      license
      maintainers
      platforms
      ;
  };
}
