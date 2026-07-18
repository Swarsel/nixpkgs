# DO *NOT* MODIFY THE LINES CONTAINING "hash = ..." OR "version = ...".
# THEY ARE GENERATED. SEE ./update.sh.
{
  stdenv,
  fetchzip,
  libjpeg,
  netcdf,
  pkgs,
}:

let
  mkGeoserverExtension =
    {
      hash,
      name,
      version,
      buildInputs ? [ ],
    }:
    stdenv.mkDerivation {
      inherit buildInputs version;
      pname = "geoserver-${name}-extension";

      src = fetchzip {
        inherit hash;
        url = "https://sourceforge.net/projects/geoserver/files/GeoServer/${version}/extensions/geoserver-${version}-${name}-plugin.zip";
        # We expect several files.
        stripRoot = false;
      };

      installPhase = ''
        runHook preInstall

        DIR=$out/share/geoserver/webapps/geoserver/WEB-INF/lib
        mkdir -p $DIR
        cp -r $src/* $DIR

        runHook postInstall
      '';
    };
in

{
  app-schema = mkGeoserverExtension {
    version = "2.28.4"; # app-schema
    hash = "sha256-qgzJP8m3CnkZHlM3Wmix9wl8M0G9m8DTJZ8HcBJx/aw="; # app-schema
    name = "app-schema";
  };

  authkey = mkGeoserverExtension {
    version = "2.28.4"; # authkey
    hash = "sha256-UDRVVPGqhCwen/irMz8YUbv01PQ4oRFJgELtzvJ6WGk="; # authkey
    name = "authkey";
  };

  cas = mkGeoserverExtension {
    version = "2.28.4"; # cas
    hash = "sha256-g0BqPXtRoIYfLps6cFCg/+DBYOZpQX/bolJcwGuCTaI="; # cas
    name = "cas";
  };

  charts = mkGeoserverExtension {
    version = "2.28.4"; # charts
    hash = "sha256-vhFVGX64M+5NfHYBNj1yMadZ2bKLwemURjwd6jp2HPM="; # charts
    name = "charts";
  };

  control-flow = mkGeoserverExtension {
    version = "2.28.4"; # control-flow
    hash = "sha256-FJj8g145s1qOoym+5SQymcSzH8bTzthUg5dWIR7ZGPU="; # control-flow
    name = "control-flow";
  };

  css = mkGeoserverExtension {
    version = "2.28.4"; # css
    hash = "sha256-9BYc4j1fk5hTT4jKdHReaoSg7bWjxmyUrOdwMospiiM="; # css
    name = "css";
  };

  csw = mkGeoserverExtension {
    version = "2.28.4"; # csw
    hash = "sha256-/+IQO/X26cMz5+aOtMDJ23ovjnmOOATSgRNs40bzM0I="; # csw
    name = "csw";
  };

  csw-iso = mkGeoserverExtension {
    version = "2.28.4"; # csw-iso
    hash = "sha256-kmUH2g18/PXBTl2cUzs2q1fzSn6BllikvatRgNlxRtc="; # csw-iso
    name = "csw-iso";
  };

  db2 = mkGeoserverExtension {
    version = "2.28.4"; # db2
    hash = "sha256-4xeE1Y6PXqlt7LCz5s86+Uj6JMV2HqrmJpIAR6pnQhk="; # db2
    name = "db2";
  };

  # Needs wps extension.
  dxf = mkGeoserverExtension {
    version = "2.28.4"; # dxf
    hash = "sha256-lfvvlennN7Ig0sV2ujAi3KpLmgqFSf1Y5m6pcpSc2wY="; # dxf
    name = "dxf";
  };

  excel = mkGeoserverExtension {
    version = "2.28.4"; # excel
    hash = "sha256-VSh9rNAnJzbfEYKELY1BRcoHRtifk3J0D08ZnF5+kTc="; # excel
    name = "excel";
  };

  feature-pregeneralized = mkGeoserverExtension {
    version = "2.28.4"; # feature-pregeneralized
    hash = "sha256-ZY7Qr3faGZOFg7zX4JFJ+FdSIhXQ1ROulcPRmGRGyAI="; # feature-pregeneralized
    name = "feature-pregeneralized";
  };

  # Note: The extension name ("gdal") clashes with pkgs.gdal.
  gdal = mkGeoserverExtension {
    version = "2.28.4"; # gdal
    buildInputs = [ pkgs.gdal ];
    hash = "sha256-7GT6XfpDjCX+TYprg4Y59UshSYa0tACIFQrtPW8vrFM="; # gdal
    name = "gdal";
  };

  # Throws "java.io.FileNotFoundException: URL [jar:file:/nix/store/.../WEB-INF/lib/gs-geofence-server-2.24.1.jar!/geofence-default-override.properties] cannot be resolved to absolute file path because it does not reside in the file system: jar:file:/nix/store/.../WEB-INF/lib/gs-geofence-server-2.24.1.jar!/geofence-default-override.properties" but seems to work out of the box.
  #geofence = mkGeoserverExtension {
  #  name = "geofence";
  #  version = "2.28.4"; # geofence
  #  hash = "sha256-620nYoPkM1GitY221F/uN9Ts8D9h7DBvXf9DAxoUGBY="; # geofence
  #};

  #geofence-server-h2 = mkGeoserverExtension {
  #  name = "geofence-server-h2";
  #  version = "2.28.4"; # geofence-server
  #  hash = "sha256-KL4VTHZ3/kfCBkvAKgCmXs+TVa2Z4Zb+UphRyVnZI2I="; # geofence-server-h2
  #};

  #geofence-server-postgres = mkGeoserverExtension {
  #  name = "geofence-server-postgres";
  #  version = "2.28.4"; # geofence-server
  #  hash = "sha256-7EVrhV6vbglGd15K81Ypygu+1tEYtZOy9wsERBu4sNM="; # geofence-server-postgres
  #};

  #geofence-wps = mkGeoserverExtension {
  #  name = "geofence-wps";
  #  version = "2.28.4"; # geofence-wps
  #  hash = "sha256-7yVXODL1Fx0KM4BSeHCa4Fw/+xE7j9LJtdpVLeWPOI8="; # geofence-wps
  #};

  geopkg-output = mkGeoserverExtension {
    version = "2.28.4"; # geopkg-output
    hash = "sha256-2CbA5opqZwwKBcM87nbY9e/i67vs70SShW08Fpryy8o="; # geopkg-output
    name = "geopkg-output";
  };

  grib = mkGeoserverExtension {
    version = "2.28.4"; # grib
    buildInputs = [ netcdf ];
    hash = "sha256-apCBtt1SOB8rimpUDny6KOjxzwMjCk+E3vdpv336iJE="; # grib
    name = "grib";
  };

  gwc-s3 = mkGeoserverExtension {
    version = "2.28.4"; # gwc-s3
    hash = "sha256-Jy3/EFNJym61st2LAysgRKsS2KBTFhkFSZc6WouO3LA="; # gwc-s3
    name = "gwc-s3";
  };

  h2 = mkGeoserverExtension {
    version = "2.28.4"; # h2
    hash = "sha256-tqchE8kkyo35rL9ESs/TD8n9CWAaWiWqe3wxKXt3Ut4="; # h2
    name = "h2";
  };

  iau = mkGeoserverExtension {
    version = "2.28.4"; # iau
    hash = "sha256-yorqFxLh9PWoC0j4WXwXs5uK1sy2gV9S1vS36ebKBIc="; # iau
    name = "iau";
  };

  importer = mkGeoserverExtension {
    version = "2.28.4"; # importer
    hash = "sha256-XGCVD/CUZjiPCzLyHec7na+fNARkBvnfR1+GbCdogXQ="; # importer
    name = "importer";
  };

  inspire = mkGeoserverExtension {
    version = "2.28.4"; # inspire
    hash = "sha256-/9juMAOOCycPeJcuB9a3DMIC8xzN1WjrzEi951utodg="; # inspire
    name = "inspire";
  };

  # Needs Kakadu plugin from
  # https://github.com/geosolutions-it/imageio-ext
  #jp2k = mkGeoserverExtension {
  #  name = "jp2k";
  #  version = "2.28.4"; # jp2k
  #  hash = "sha256-IfGThXCIEkmoTlA3EdIWekFDGBw3K+yqO49RZFDfAeQ="; # jp2k
  #};

  # Throws "java.lang.UnsatisfiedLinkError: 'void org.libjpegturbo.turbojpeg.TJDecompressor.init()'"
  # as of 2.28.1.
  # NOTE: When re-enabling this, RE-ENABLE THE CORRESPONDING TEST, TOO! (See tests/geoserver.nix)
  #libjpeg-turbo = mkGeoserverExtension {
  #  name = "libjpeg-turbo";
  #  version = "2.28.4"; # libjpeg-turbo
  #  hash = "sha256-05aP0WypGM0dz/OXM/1paYgmmwGGcU7j34kYdJIlL0U="; # libjpeg-turbo
  #  buildInputs = [ libjpeg.out ];
  #};

  mapml = mkGeoserverExtension {
    version = "2.28.4"; # mapml
    hash = "sha256-fZVPUqUlNx2xvh9qEJgIX+rfvT2ZeLjb8SgTEdYC4FI="; # mapml
    name = "mapml";
  };

  mbstyle = mkGeoserverExtension {
    version = "2.28.4"; # mbstyle
    hash = "sha256-OHEJ5u1r4KcikluRjah1S137IjbDDtGtVQQbqczjoco="; # mbstyle
    name = "mbstyle";
  };

  metadata = mkGeoserverExtension {
    version = "2.28.4"; # metadata
    hash = "sha256-pL1Xti6+TUPN0ujpJjGRt26q3ItEKQa37loNpmQvwVs="; # metadata
    name = "metadata";
  };

  mongodb = mkGeoserverExtension {
    version = "2.28.4"; # mongodb
    hash = "sha256-XwQAKp6XZH3W4qsNjhmA73hf6SjINz9/SOPwb2wGdcU="; # mongodb
    name = "mongodb";
  };

  monitor = mkGeoserverExtension {
    version = "2.28.4"; # monitor
    hash = "sha256-JhmsDRoHGbTBCKxKqlxdpmn2WGC/aQnyeuWLs1u0xFE="; # monitor
    name = "monitor";
  };

  mysql = mkGeoserverExtension {
    version = "2.28.4"; # mysql
    hash = "sha256-f8xdJ2WVYQV+HG5U2J/1vKBAFo5srFWSPXVAyRUt8kE="; # mysql
    name = "mysql";
  };

  netcdf = mkGeoserverExtension {
    version = "2.28.4"; # netcdf
    buildInputs = [ netcdf ];
    hash = "sha256-wU5MkTYgxxOgBBybbbeHtT2Rj1CoTFBTjGzyLPlPT7A="; # netcdf
    name = "netcdf";
  };

  netcdf-out = mkGeoserverExtension {
    version = "2.28.4"; # netcdf-out
    buildInputs = [ netcdf ];
    hash = "sha256-0RIRTDtTUEj9OUDpAD1LbCY1iGCbXAKbgmH7ZkNHWhM="; # netcdf-out
    name = "netcdf-out";
  };

  ogr-wfs = mkGeoserverExtension {
    version = "2.28.4"; # ogr-wfs
    buildInputs = [ pkgs.gdal ];
    hash = "sha256-UAsTKEMVlYTrCpbs8++Kxdn0w6ejzMiPrT7S2NlMNxc="; # ogr-wfs
    name = "ogr-wfs";
  };

  # Needs ogr-wfs extension.
  ogr-wps = mkGeoserverExtension {
    version = "2.28.4"; # ogr-wps
    # buildInputs = [ pkgs.gdal ];
    hash = "sha256-sjV0YwR21GQYt4YuDIE2H+5UQ2qRmP7tWVyOXNuLkSM="; # ogr-wps
    name = "ogr-wps";
  };

  oracle = mkGeoserverExtension {
    version = "2.28.4"; # oracle
    hash = "sha256-xiIPgpWCDycE6rTW49QnB/7rHbns1GJhWCdIfMEBuXE="; # oracle
    name = "oracle";
  };

  params-extractor = mkGeoserverExtension {
    version = "2.28.4"; # params-extractor
    hash = "sha256-/AOjfsA58btiOBv4zvF4jdLt2lE5GPDKUKzNZyX8fI0="; # params-extractor
    name = "params-extractor";
  };

  printing = mkGeoserverExtension {
    version = "2.28.4"; # printing
    hash = "sha256-smytiUVPKq31YyWE/xLwiGPLQ6DxScj2gHjMbgKCjMc="; # printing
    name = "printing";
  };

  pyramid = mkGeoserverExtension {
    version = "2.28.4"; # pyramid
    hash = "sha256-xfOzBm5eTbzfRRiMQ63i29GW91IxWKIotrSUa6BgD5M="; # pyramid
    name = "pyramid";
  };

  querylayer = mkGeoserverExtension {
    version = "2.28.4"; # querylayer
    hash = "sha256-WyLyUoLfv8JIKBqjphcXgWBbtkJEB3ig4cyY158lRQk="; # querylayer
    name = "querylayer";
  };

  sldservice = mkGeoserverExtension {
    version = "2.28.4"; # sldservice
    hash = "sha256-DsN9tKZshcsz6/IsPA0l757YtmsakBi/NbgEUwnfafs="; # sldservice
    name = "sldservice";
  };

  sqlserver = mkGeoserverExtension {
    version = "2.28.4"; # sqlserver
    hash = "sha256-MBMU4pJKgS3qra9pli8SAnOtIiDU2zD0sXJaKXlr0+A="; # sqlserver
    name = "sqlserver";
  };

  vectortiles = mkGeoserverExtension {
    version = "2.28.4"; # vectortiles
    hash = "sha256-6E3lwH573lTSMYtQ00b3fVtJYSsIFETwT7JAZHI6ubQ="; # vectortiles
    name = "vectortiles";
  };

  wcs2_0-eo = mkGeoserverExtension {
    version = "2.28.4"; # wcs2_0-eo
    hash = "sha256-w30lrzli6++7NDu59QsRFxyIQBMSV7M5BeTqGSJmw18="; # wcs2_0-eo
    name = "wcs2_0-eo";
  };

  web-resource = mkGeoserverExtension {
    version = "2.28.4"; # web-resource
    hash = "sha256-GH0foPjbBcKOXahqgPv+02Jex3ZE5XKmeWNDew0DKF4="; # web-resource
    name = "web-resource";
  };

  wmts-multi-dimensional = mkGeoserverExtension {
    version = "2.28.4"; # wmts-multi-dimensional
    hash = "sha256-gi8qwwKG9K1l4AJ05vDGykxCmd42oSFSZtwhDwDI8m0="; # wmts-multi-dimensional
    name = "wmts-multi-dimensional";
  };

  wps = mkGeoserverExtension {
    version = "2.28.4"; # wps
    hash = "sha256-2qh7fDeJAswTb+P60zNQeH1nc0886Dfh7pWpUWCaEKc="; # wps
    name = "wps";
  };

  # Needs hazelcast (https://github.com/hazelcast/hazelcast (?)) which is not
  # available in nixpgs as of 2024/01.
  #wps-cluster-hazelcast = mkGeoserverExtension {
  #  name = "wps-cluster-hazelcast";
  #  version = "2.28.4"; # wps-cluster-hazelcast
  #  hash = "sha256-r9BpjvFL00lgTrbhIxY7c16sGu6ujKJ6D4oDz61KekA="; # wps-cluster-hazelcast
  #};

  wps-download = mkGeoserverExtension {
    version = "2.28.4"; # wps-download
    hash = "sha256-MAL71aYRKOFSKnhj+3dxZhCDQL/6GAeAtB11Zs6C5tI="; # wps-download
    name = "wps-download";
  };

  # Needs Postrgres configuration or similar.
  # See https://docs.geoserver.org/main/en/user/extensions/wps-jdbc/index.html
  wps-jdbc = mkGeoserverExtension {
    version = "2.28.4"; # wps-jdbc
    hash = "sha256-QBydO6EKLe22W+3pCP4p9TqMyp1KeKReyeidL5yxndo="; # wps-jdbc
    name = "wps-jdbc";
  };

  ysld = mkGeoserverExtension {
    version = "2.28.4"; # ysld
    hash = "sha256-Qg+wzMzRebqqOAK4Y7hsfcTyKcz/E5Fw/fHLcUr3KwY="; # ysld
    name = "ysld";
  };

}
