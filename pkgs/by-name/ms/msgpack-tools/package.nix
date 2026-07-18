{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  cmake,
  libb64,
  rapidjson,
  replaceVars,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "msgpack-tools";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "ludocode";
    repo = "msgpack-tools";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RT85vw6QeVkuNC2mtoT/BJyU0rdQVfz6ZBJf+ouY8vk=";
  };

  patches = [
    ./cmake-v4.patch
    (replaceVars ./use-nix-deps.patch {
      libb64 = "${libb64}";
      rapidjson = "${rapidjson}";
    })
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    rapidjson
    libb64
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  mpack = fetchurl {
    hash = "sha256-hyiXygbAHnNgF4TIg+DemBvtdBnSgJ7fAhknVuL+T/c=";
    url = "https://github.com/ludocode/mpack/archive/df17e83f0fa8571b9cd0d8ccf38144fa90e244d1.tar.gz";
  };

  postUnpack = ''
    mkdir $sourceRoot/contrib
    cp ${finalAttrs.mpack} $sourceRoot/contrib/mpack-df17e83f0fa8571b9cd0d8ccf38144fa90e244d1.tar.gz
  '';

  versionCheckProgram = "${placeholder "out"}/bin/json2msgpack";
  versionCheckProgramArg = "-v";

  meta = {
    description = "Command-line tools for converting between MessagePack and JSON";
    homepage = "https://github.com/ludocode/msgpack-tools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ deejayem ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
