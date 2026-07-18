{
  lib,
  stdenv,
  fetchurl,
  graylogPackage,
  unzip,
}:

let
  inherit (lib)
    licenses
    sourceTypes
    ;

  glPlugin =
    a@{
      pluginName,
      version,
      installPhase ? ''
        mkdir -p $out/bin
        cp $src $out/bin/${pluginName}-${version}.jar
      '',
      ...
    }:
    stdenv.mkDerivation (
      a
      // {
        inherit installPhase;
        nativeBuildInputs = [ unzip ];
        dontUnpack = true;

        meta = a.meta // {
          sourceProvenance = with sourceTypes; [ binaryBytecode ];
          platforms = graylogPackage.meta.platforms;
        };
      }
    );
in
{
  aggregates = glPlugin rec {
    pname = "graylog-aggregates";
    version = "2.4.0";

    src = fetchurl {
      url = "https://github.com/cvtienhoven/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "1c48almnjr0b6nvzagnb9yddqbcjs7yhrd5yc5fx9q7w3vxi50zp";
    };

    pluginName = "graylog-plugin-aggregates";

    meta = {
      description = "Plugin that enables users to execute term searches and get notified when the given criteria are met";
      homepage = "https://github.com/cvtienhoven/graylog-plugin-aggregates";
    };
  };

  auth_sso = glPlugin rec {
    pname = "graylog-auth-sso";
    version = "3.3.0";

    src = fetchurl {
      url = "https://github.com/Graylog2/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "1g47hlld8vzicd47b5i9n2816rbrhv18vjq8gp765c7mdg4a2jn8";
    };

    pluginName = "graylog-plugin-auth-sso";

    meta = {
      description = "SSO support for Graylog through trusted HTTP headers set by load balancers or authentication proxies";
      homepage = "https://github.com/Graylog2/graylog-plugin-auth-sso";
    };
  };

  dnsresolver = glPlugin rec {
    pname = "graylog-dnsresolver";
    version = "1.2.0";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "0djlyd4w4mrrqfbrs20j1xw0fygqsb81snz437v9bf80avmcyzg1";
    };

    pluginName = "graylog-plugin-dnsresolver";

    meta = {
      description = "Message filter plugin can be used to do DNS lookups for the source field in Graylog messages";
      homepage = "https://github.com/graylog-labs/graylog-plugin-dnsresolver";
    };
  };

  enterprise-integrations = glPlugin rec {
    pname = "graylog-enterprise-integrations";
    version = "3.3.9";

    src = fetchurl {
      url = "https://downloads.graylog.org/releases/graylog-enterprise-integrations/graylog-enterprise-integrations-plugins-${version}.tgz";
      sha256 = "0yr2lmf50w8qw5amimmym6y4jxga4d7s7cbiqs5sqzvipgsknbwj";
    };

    installPhase = ''
      mkdir -p $out/bin
      tar --strip-components=2 -xf $src
      cp ${pluginName}-${version}.jar $out/bin/${pluginName}-${version}.jar
    '';

    pluginName = "graylog-plugin-enterprise-integrations";

    meta = {
      description = "Integrations are tools that help Graylog work with external systems (unfree enterprise integrations)";
      homepage = "https://docs.graylog.org/en/3.3/pages/integrations.html#enterprise";
      license = licenses.unfree;
    };
  };

  filter-messagesize = glPlugin rec {
    pname = "graylog-filter-messagesize";
    version = "0.0.2";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "1vx62yikd6d3lbwsfiyf9j6kx8drvn4xhffwv27fw5jzhfqr61ji";
    };

    pluginName = "graylog-plugin-filter-messagesize";

    meta = {
      description = "Prints out all messages that have an estimated size crossing a configured threshold during processing";
      homepage = "https://github.com/graylog-labs/graylog-plugin-filter-messagesize";
    };
  };

  integrations = glPlugin rec {
    pname = "graylog-integrations";
    version = "3.3.9";

    src = fetchurl {
      url = "https://downloads.graylog.org/releases/graylog-integrations/graylog-integrations-plugins-${version}.tgz";
      sha256 = "0q858ffmkinngyqqsaszcrx93zc4fg43ny0xb7vm0p4wd48hjyqc";
    };

    installPhase = ''
      mkdir -p $out/bin
      tar --strip-components=2 -xf $src
      cp ${pluginName}-${version}.jar $out/bin/${pluginName}-${version}.jar
    '';

    pluginName = "graylog-plugin-integrations";

    meta = {
      description = "Collection of open source Graylog integrations that will be released together";
      homepage = "https://github.com/Graylog2/graylog-plugin-integrations";
    };
  };

  internal-logs = glPlugin rec {
    pname = "graylog-internal-logs";
    version = "2.4.0";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "1jyy0wkjapv3xv5q957xxv2pcnd4n1yivkvkvg6cx7kv1ip75xwc";
    };

    pluginName = "graylog-plugin-internal-logs";

    meta = {
      description = "Graylog plugin to record internal logs of Graylog efficiently instead of sending them over the network";
      homepage = "https://github.com/graylog-labs/graylog-plugin-internal-logs";
    };
  };

  ipanonymizer = glPlugin rec {
    pname = "graylog-ipanonymizer";
    version = "1.1.2";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "0hd66751hp97ddkn29s1cmjmc2h1nrp431bq7d2wq16iyxxlygri";
    };

    pluginName = "graylog-plugin-ipanonymizer";

    meta = {
      description = "Graylog-server plugin that replaces the last octet of IP addresses in messages with xxx";
      homepage = "https://github.com/graylog-labs/graylog-plugin-ipanonymizer";
    };
  };

  jabber = glPlugin rec {
    pname = "graylog-jabber";
    version = "2.4.0";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "0zy27q8y0bv7i5nypsfxad4yiw121sbwzd194jsz2w08jhk3skl5";
    };

    pluginName = "graylog-plugin-jabber";

    meta = {
      description = "Jabber Alarmcallback Plugin for Graylog";
      homepage = "https://github.com/graylog-labs/graylog-plugin-jabber";
    };
  };

  metrics = glPlugin rec {
    pname = "graylog-metrics";
    version = "1.3.0";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "1v1yzmqp43kxigh3fymdwki7pn21sk2ym3kk4nn4qv4zzkhz59vp";
    };

    pluginName = "graylog-plugin-metrics";

    meta = {
      description = "Output plugin for integrating Graphite, Ganglia and StatsD with Graylog";
      homepage = "https://github.com/graylog-labs/graylog-plugin-metrics";
    };
  };

  mongodb-profiler = glPlugin rec {
    pname = "graylog-mongodb-profiler";
    version = "2.0.1";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "1hadxyawdz234lal3dq5cy3zppl7ixxviw96iallyav83xyi23i8";
    };

    pluginName = "graylog-plugin-mongodb-profiler";

    meta = {
      description = "Graylog input plugin that reads MongoDB profiler data";
      homepage = "https://github.com/graylog-labs/graylog-plugin-mongodb-profiler";
    };
  };

  pagerduty = glPlugin rec {
    pname = "graylog-pagerduty";
    version = "2.0.0";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "0xhcwfwn7c77giwjilv7k7aijnj9azrjbjgd0r3p6wdrw970f27r";
    };

    pluginName = "graylog-plugin-pagerduty";

    meta = {
      description = "Alarm callback plugin for integrating PagerDuty into Graylog";
      homepage = "https://github.com/graylog-labs/graylog-plugin-pagerduty";
    };
  };

  redis = glPlugin rec {
    pname = "graylog-redis";
    version = "0.1.1";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "0dfgh6w293ssagas5y0ixwn0vf54i5iv61r5p2q0rbv2da6xvhbw";
    };

    pluginName = "graylog-plugin-redis";

    meta = {
      description = "Redis plugin for Graylog";
      homepage = "https://github.com/graylog-labs/graylog-plugin-redis";
    };
  };

  slack = glPlugin rec {
    pname = "graylog-slack";
    version = "3.1.0";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "067p8g94b007gypwyyi8vb6qhwdanpk8ah57abik54vv14jxg94k";
    };

    pluginName = "graylog-plugin-slack";

    meta = {
      description = "Can notify Slack or Mattermost channels about triggered alerts in Graylog (Alarm Callback)";
      homepage = "https://github.com/graylog-labs/graylog-plugin-slack";
    };
  };

  smseagle = glPlugin rec {
    pname = "graylog-smseagle";
    version = "1.0.1";

    src = fetchurl {
      url = "https://bitbucket.org/proximus/smseagle-graylog/raw/b99cfc349aafc7c94d4c2503f7c3c0bde67684d1/jar/${pluginName}-${version}.jar";
      sha256 = "sha256-rvvftzPskXRGs1Z9dvd/wFbQoIoNtEQIFxMIpSuuvf0=";
    };

    pluginName = "graylog-plugin-smseagle";

    meta = {
      description = "Alert/notification callback plugin for integrating the SMSEagle into Graylog";
      homepage = "https://bitbucket.org/proximus/smseagle-graylog/";
      license = licenses.gpl3Only;
    };
  };

  snmp = glPlugin rec {
    pname = "graylog-snmp";
    version = "0.3.0";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "1hkaklwzcsvqq45b98chwqxqdgnnbj4dg68agsll13yq4zx37qpp";
    };

    pluginName = "graylog-plugin-snmp";

    meta = {
      description = "Graylog plugin to receive SNMP traps";
      homepage = "https://github.com/graylog-labs/graylog-plugin-snmp";
    };
  };

  spaceweather = glPlugin rec {
    pname = "graylog-spaceweather";
    version = "1.0";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/spaceweather-input.jar";
      sha256 = "1mwqy3fhyy4zdwyrzvbr565xwf96xs9d3l70l0khmrm848xf8wz4";
    };

    pluginName = "graylog-plugin-spaceweather";

    meta = {
      description = "Correlate proton density to the response time of your app and the ion temperature to your exception rate";
      homepage = "https://github.com/graylog-labs/graylog-plugin-spaceweather";
    };
  };

  splunk = glPlugin rec {
    pname = "graylog-splunk";
    version = "0.5.0-rc.1";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "sha256-EwF/Dc8GmMJBTxH9xGZizUIMTGSPedT4bprorN6X9Os=";
    };

    pluginName = "graylog-plugin-splunk";

    meta = {
      description = "Graylog output plugin that forwards one or more streams of data to Splunk via TCP";
      homepage = "https://github.com/graylog-labs/graylog-plugin-splunk";
      license = licenses.gpl3Only;
    };
  };

  twiliosms = glPlugin rec {
    pname = "graylog-twiliosms";
    version = "1.0.0";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "0kwfv1zfj0fmxh9i6413bcsaxrn1vdwrzb6dphvg3dx27wxn1j1a";
    };

    pluginName = "graylog-plugin-twiliosms";

    meta = {
      description = "Alarm callback plugin for integrating the Twilio SMS API into Graylog";
      homepage = "https://github.com/graylog-labs/graylog-plugin-twiliosms";
    };
  };

  twitter = glPlugin rec {
    pname = "graylog-twitter";
    version = "2.0.0";

    src = fetchurl {
      url = "https://github.com/graylog-labs/${pluginName}/releases/download/${version}/${pluginName}-${version}.jar";
      sha256 = "1pi34swy9nzq35a823zzvqrjhb6wsg302z31vk2y656sw6ljjxyh";
    };

    pluginName = "graylog-plugin-twitter";

    meta = {
      description = "Graylog input plugin that reads Twitter messages based on keywords in realtime";
      homepage = "https://github.com/graylog-labs/graylog-plugin-twitter";
    };
  };
}
