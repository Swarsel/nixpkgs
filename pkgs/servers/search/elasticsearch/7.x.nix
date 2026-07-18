{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  coreutils,
  elk7Version,
  gnugrep,
  jre_headless,
  makeWrapper,
  util-linux,
  zlib,
}:

let
  info = lib.splitString "-" stdenv.hostPlatform.system;
  arch = lib.elemAt info 0;
  plat = lib.elemAt info 1;
  hashes = {
    aarch64-darwin = "sha512-uq5VVwvbOX4Rv32iLFw+RalFPBxQqA+1hBjFw3svzOaD1caOOrGHD4lJVHFxsFw0xl//AZuSG7S3r7Eh9AmWvQ==";
    aarch64-linux = "sha512-MPrDfBMcwNCgWW8dpOeAtlz9Odfk/0z8i+Rn08hTp35kU849KdPQLTmexlvnf/jVwqfwzN2xWJtNF0sQO26pUA==";
    x86_64-linux = "sha512-xlbdx/fFQxilECdDiN80U+s+huBowo9Qf5tDIYwZ1z9gUCriNL0rMNDkvzUDL73BEI3WMFMqHdbi3cn7b5l9gA==";
  };
in
stdenv.mkDerivation rec {
  pname = "elasticsearch";
  version = elk7Version;

  src = fetchurl {
    url = "https://artifacts.elastic.co/downloads/elasticsearch/${pname}-${version}-${plat}-${arch}.tar.gz";
    hash = hashes.${stdenv.hostPlatform.system} or (throw "Unknown architecture");
  };

  patches = [ ./es-home-6.x.patch ];

  postPatch = ''
    substituteInPlace bin/elasticsearch-env --replace \
      "ES_CLASSPATH=\"\$ES_HOME/lib/*\"" \
      "ES_CLASSPATH=\"$out/lib/*\""

    substituteInPlace bin/elasticsearch-cli --replace \
      "ES_CLASSPATH=\"\$ES_CLASSPATH:\$ES_HOME/\$additional_classpath_directory/*\"" \
      "ES_CLASSPATH=\"\$ES_CLASSPATH:$out/\$additional_classpath_directory/*\""
  '';

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optional (!stdenv.hostPlatform.isDarwin) autoPatchelfHook;

  buildInputs = [
    jre_headless
    util-linux
    zlib
  ];

  installPhase = ''
    mkdir -p $out
    cp -R bin config lib modules plugins $out

    chmod +x $out/bin/*

    substituteInPlace $out/bin/elasticsearch \
      --replace 'bin/elasticsearch-keystore' "$out/bin/elasticsearch-keystore"

    wrapProgram $out/bin/elasticsearch \
      --prefix PATH : "${
        lib.makeBinPath [
          util-linux
          coreutils
          gnugrep
        ]
      }" \
      --set JAVA_HOME "${jre_headless}"

    wrapProgram $out/bin/elasticsearch-plugin --set JAVA_HOME "${jre_headless}"
  '';

  runtimeDependencies = [ zlib ];

  passthru = {
    enableUnfree = true;
  };

  meta = {
    description = "Open Source, Distributed, RESTful Search Engine";
    license = lib.licenses.elastic20;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];

    maintainers = with lib.maintainers; [
      basvandijk
    ];

    platforms = lib.platforms.unix;
  };
}
