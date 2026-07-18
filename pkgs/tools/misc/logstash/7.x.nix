{
  lib,
  stdenv,
  fetchurl,
  config,
  elk7Version,
  jre,
  makeWrapper,
  nixosTests,
  enableUnfree ? true,
}:

let
  info = lib.splitString "-" stdenv.hostPlatform.system;
  arch = lib.elemAt info 0;
  plat = lib.elemAt info 1;
  hashes =
    if enableUnfree then
      {
        aarch64-linux = "sha512-V2Nt/lup4ofgoMqpAH3OHF8Fp0PvC1M8nl6sCKmTf+ZXQYHNjAJkJwGJwHeQQ0L/348JHyCkeWL43dS7Jr6ZJQ==";
        x86_64-linux = "sha512-9JzopnY43Osoy4/0G9gxJYlbCl1a9Qy2pL4GL1uyjJ3uSNoOskEBhhsqLp9BhtJXOaquuRDgbJnXhbBrlE0rKg==";
      }
    else
      {
        aarch64-linux = "sha512-iVft0kZYhvFJ1NKCfdePhRxDljPTwV+3G7wV94iykYISgLTVoehzDTMdxUyfK/mmQhu3hmmHbVpw1jXjTrS7ng==";
        x86_64-linux = "sha512-L11ZUdXC8VDiSEVDBMous2OaMlAFgvkQ+eDbmbA9r/sDIXY8W7dx3jgPNXoorDtatTemwy8aXw1XJGaVmj4T3Q==";
      };
  this = stdenv.mkDerivation rec {
    pname = "logstash${lib.optionalString (!enableUnfree) "-oss"}";
    version = elk7Version;

    src = fetchurl {
      url = "https://artifacts.elastic.co/downloads/logstash/${pname}-${version}-${plat}-${arch}.tar.gz";
      hash = hashes.${stdenv.hostPlatform.system} or (throw "Unknown architecture");
    };

    nativeBuildInputs = [
      makeWrapper
    ];

    buildInputs = [
      jre
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r {Gemfile*,modules,vendor,lib,bin,config,data,logstash-core,logstash-core-plugin-api} $out

      patchShebangs $out/bin/logstash
      patchShebangs $out/bin/logstash-plugin

      wrapProgram $out/bin/logstash \
         --set JAVA_HOME "${jre}"

      wrapProgram $out/bin/logstash-plugin \
         --set JAVA_HOME "${jre}"
      runHook postInstall
    '';

    dontBuild = true;
    dontPatchELF = true;
    dontPatchShebangs = true;
    dontStrip = true;

    passthru.tests = lib.optionalAttrs (config.allowUnfree && enableUnfree) (
      assert this.drvPath == nixosTests.elk.unfree.ELK-7.elkPackages.logstash.drvPath;
      {
        elk = nixosTests.elk.unfree.ELK-7;
      }
    );

    meta = {
      description = "Logstash is a data pipeline that helps you process logs and other event data from a variety of systems";
      homepage = "https://www.elastic.co/products/logstash";
      license = if enableUnfree then lib.licenses.elastic20 else lib.licenses.asl20;

      sourceProvenance = with lib.sourceTypes; [
        fromSource
        binaryBytecode # source bundles dependencies as jars
        binaryNativeCode # bundled jruby includes native code
      ];

      maintainers = with lib.maintainers; [
        basvandijk
      ];

      platforms = lib.platforms.unix;
    };
  };
in
this
