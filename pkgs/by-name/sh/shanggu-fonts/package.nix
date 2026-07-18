{
  lib,
  fetchurl,
  p7zip,
  stdenvNoCC,
}:
let
  version = "1.028";

  source =
    with lib.attrsets;
    mapAttrs'
      (
        name: hash:
        nameValuePair (lib.strings.toLower name) (fetchurl {
          inherit hash;
          url = "https://github.com/GuiWonder/Shanggu/releases/download/${version}/Shanggu${name}TTCs.7z";
        })
      )
      {
        Mono = "sha256-QQgEUQbWOr3sOIT2yQpkY9cL2sHFO/Z/hrhV5YqA3Zk=";
        Round = "sha256-izPntZyAfeL/DuhDvZ+FWKq71Uj4WuHWC4d7Z3qEsvc=";
        Sans = "sha256-a05MO8vq+PqDlYtuDstN6hlx/IkNY0JCwcmlYYK3Xcw=";
        Serif = "sha256-A1/KygN+OC1e3p8T6OAN8jCAi8HuswkE/xjo65GVweY=";
      };

  extraOutputs = builtins.attrNames source;
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "shanggu-fonts";
  outputs = [ "out" ] ++ extraOutputs;
  nativeBuildInputs = [ p7zip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
  ''
  + lib.strings.concatLines (
    lib.lists.forEach extraOutputs (name: ''
      install -Dm444 ${name}/*.ttc -t ${placeholder name}/share/fonts/truetype
      ln -s "${placeholder name}" /share/fonts/truetype/*.ttc $out/share/fonts/truetype
    '')
  )
  + ''
    runHook postInstall
  '';

  unpackPhase = ''
    runHook preUnpack
  ''
  + lib.strings.concatLines (
    lib.attrsets.mapAttrsToList (name: value: ''
      7z x ${value} -o${name}
    '') source
  )
  + ''
    runHook postUnpack
  '';

  meta = {
    description = "Heritage glyph (old glyph) font based on Siyuan";
    homepage = "https://github.com/GuiWonder/Shanggu";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ Cryolitia ];
    platforms = lib.platforms.all;
  };
}
