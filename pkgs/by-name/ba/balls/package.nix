{
  lib,
  fetchFromGitHub,
  buildNimPackage,
  makeWrapper,
  nim,
}:

buildNimPackage (finalAttrs: {
  pname = "balls";
  version = "5.4.0";

  src = fetchFromGitHub {
    owner = "disruptek";
    repo = "balls";
    rev = finalAttrs.version;
    hash = "sha256-CMYkMkekVI0C1WUds+KBbRfjMte42kBAB2ddtQp8d+k=";
  };

  postPatch =
    # Trim comments from the Nimble file.
    ''
      sed \
        -e 's/[[:space:]]* # .*$//g' \
       -i balls.nimble
    '';

  nativeBuildInputs = [ makeWrapper ];

  preCheck = ''
    echo 'path:"$projectDir/.."' > tests/nim.cfg
  '';

  postFixup =
    let
      lockAttrs = builtins.fromJSON (builtins.readFile finalAttrs.lockFile);
      pathFlagOfFod = { path, srcDir, ... }: ''"--path:${path}/${srcDir}"'';
      pathFlags = map pathFlagOfFod lockAttrs.depends;
    in
    ''
      wrapProgram $out/bin/balls \
        --suffix PATH : ${lib.makeBinPath [ nim ]} \
        --append-flags '--path:"${finalAttrs.src}" ${toString pathFlags}'
    '';

  lockFile = ./lock.json;

  meta = finalAttrs.src.meta // {
    description = "Testing framework with balls";
    homepage = "https://github.com/disruptek/balls";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "balls";
  };
})
