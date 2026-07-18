{
  lib,
  stdenv,
  fetchurl,
  _7zz,
  autoPatchelfHook,
  fixDarwinDylibNames,
  libaio,
  makeWrapper,
  unixodbc,
  unzip,
  odbcSupport ? true,
}:

assert odbcSupport -> unixodbc != null;

let
  inherit (lib) optional optionals optionalString;

  throwSystem = throw "Unsupported system: ${stdenv.hostPlatform.system}";

  # assemble list of components
  components = [
    "basic"
    "sdk"
    "sqlplus"
    "tools"
  ]
  ++ optional odbcSupport "odbc";

  # determine the version number, there might be different ones per architecture
  version =
    {
      aarch64-darwin = "23.3.0.23.09";
      aarch64-linux = "19.10.0.0.0";
      x86_64-linux = "21.10.0.0.0";
    }
    .${stdenv.hostPlatform.system} or throwSystem;

  directory =
    {
      aarch64-darwin = "233023";
      aarch64-linux = "191000";
      x86_64-linux = "2110000";
    }
    .${stdenv.hostPlatform.system} or throwSystem;

  # hashes per component and architecture
  hashes =
    {
      aarch64-darwin = {
        basic = "sha256-G83bWDhw9wwjLVee24oy/VhJcCik7/GtKOzgOXuo1/4=";
        odbc = "sha256-JzoSdH7mJB709cdXELxWzpgaNTjOZhYH/wLkdzKA2N0=";
        sdk = "sha256-PerfzgietrnAkbH9IT7XpmaFuyJkPHx0vl4FCtjPzLs=";
        sqlplus = "sha256-khOjmaExAb3rzWEwJ/o4XvRMQruiMw+UgLFtsOGn1nY=";
        tools = "sha256-gA+SbgXXpY12TidpnjBzt0oWQ5zLJg6wUpzpSd/N5W4=";
      };

      aarch64-linux = {
        basic = "sha256-DNntH20BAmo5kOz7uEgW2NXaNfwdvJ8l8oMnp50BOsY=";
        odbc = "sha256-T+RIIKzZ9xEg/E72pfs5xqHz2WuIWKx/oRfDrQbw3ms=";
        sdk = "sha256-8VpkNyLyFMUfQwbZpSDV/CB95RoXfaMr8w58cRt/syw=";
        sqlplus = "sha256-iHcyijHhAvjsAqN9R+Rxo2R47k940VvPbScc2MWYn0Q=";
        tools = "sha256-4QY0EwcnctwPm6ZGDZLudOFM4UycLFmRIluKGXVwR0M=";
      };

      x86_64-linux = {
        basic = "sha256-uo0QBOmx7TQyroD+As60IhjEkz//+0Cm1tWvLI3edaE=";
        odbc = "sha256-3M6/cEtUrIFzQay8eHNiLGE+L0UF+VTmzp4cSBcrzlk=";
        sdk = "sha256-TIBFi1jHLJh+SUNFvuL7aJpxh61hG6gXhFIhvdPgpts=";
        sqlplus = "sha256-mF9kLjhZXe/fasYDfmZrYPL2CzAp3xDbi624RJDA4lM=";
        tools = "sha256-ay8ynzo1fPHbCg9GoIT5ja//iZPIZA2yXI/auVExiRY=";
      };
    }
    .${stdenv.hostPlatform.system} or throwSystem;

  # rels per component and architecture, optional
  rels =
    {
      aarch64-darwin = {
        basic = "1";
        tools = "1";
      };
    }
    .${stdenv.hostPlatform.system} or { };

  # convert platform to oracle architecture names
  arch =
    {
      aarch64-darwin = "macos.arm64";
      aarch64-linux = "linux.arm64";
      x86_64-linux = "linux.x64";
    }
    .${stdenv.hostPlatform.system} or throwSystem;

  shortArch =
    {
      aarch64-darwin = "mac";
      aarch64-linux = "linux";
      x86_64-linux = "linux";
    }
    .${stdenv.hostPlatform.system} or throwSystem;

  suffix =
    {
      aarch64-darwin = ".dmg";
    }
    .${stdenv.hostPlatform.system} or "dbru.zip";

  # calculate the filename of a single zip file
  srcFilename =
    component: arch: version: rel:
    "instantclient-${component}-${arch}-${version}" + (optionalString (rel != "") "-${rel}") + suffix;

  # fetcher for the non clickthrough artifacts
  fetcher =
    srcFilename: hash:
    fetchurl {
      sha256 = hash;
      url = "https://download.oracle.com/otn_software/${shortArch}/instantclient/${directory}/${srcFilename}";
    };

  # assemble srcs
  srcs = map (
    component:
    (fetcher (srcFilename component arch version rels.${component} or "") hashes.${component} or "")
  ) components;

  isDarwinAarch64 = stdenv.hostPlatform.system == "aarch64-darwin";

  pname = "oracle-instantclient";
  extLib = stdenv.hostPlatform.extensions.sharedLibrary;
in
stdenv.mkDerivation {
  inherit pname version srcs;

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  nativeBuildInputs = [
    makeWrapper
    (if isDarwinAarch64 then _7zz else unzip)
  ]
  ++ optional stdenv.hostPlatform.isLinux autoPatchelfHook
  ++ optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
  ]
  ++ optional stdenv.hostPlatform.isLinux libaio
  ++ optional odbcSupport unixodbc;

  installPhase = ''
    mkdir -p "$out/"{bin,include,lib,"share/java","share/${pname}-${version}/demo/"} $lib/lib
    install -Dm755 {adrci,genezi,uidrvci,sqlplus,exp,expdp,imp,impdp} $out/bin

    # cp to preserve symlinks
    cp -P *${extLib}* $lib/lib

    install -Dm644 *.jar $out/share/java
    install -Dm644 sdk/include/* $out/include
    install -Dm644 sdk/demo/* $out/share/${pname}-${version}/demo

    # provide alias
    ln -sfn $out/bin/sqlplus $out/bin/sqlplus64
  '';

  postFixup = optionalString stdenv.hostPlatform.isDarwin ''
    for exe in "$out/bin/"* ; do
      if [ ! -L "$exe" ]; then
        install_name_tool -add_rpath "$lib/lib" "$exe"
      fi
    done
  '';

  unpackCmd = if isDarwinAarch64 then "7zz x $curSrc -aoa -oinstantclient" else "unzip $curSrc";

  meta = {
    description = "Oracle instant client libraries and sqlplus CLI";

    longDescription = ''
      Oracle instant client provides access to Oracle databases (OCI,
      OCCI, Pro*C, ODBC or JDBC). This package includes the sqlplus
      command line SQL client.
    '';

    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ dylanmtaylor ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    hydraPlatforms = [ ];
  };
}
