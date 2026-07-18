# This module defines the global list of uids and gids.  We keep a
# central list to prevent id collisions.

# IMPORTANT!
#
# https://github.com/NixOS/rfcs/blob/master/rfcs/0052-dynamic-ids.md
#
# Use of static ids is deprecated within NixOS. Dynamic allocation is
# required, barring special circumstances. Please check if the service
# is applicable for systemd's DynamicUser option and does not need a
# uid/gid allocation at all. If DynamicUser is problematic consider
# making a `isSystemUser=true` user with the uid and gid unset and let
# NixOS pick dynamic persistent ids on activation. These IDs are persisted
# locally on the host in the event that the user is removed and added back.
# Systemd will also change ownership of service directories using the
# RuntimeDirectory/StateDirectory options just in case a change happens.
# It's only for special circumstances like for example the ids being hardcoded
# in the application or the ids having to be consistent across multiple hosts
# that configuring static ids in this file makes sense.

{ lib, ... }:

let
  inherit (lib) types;
in
{
  options = {

    ids.gids = lib.mkOption {
      description = ''
        The group IDs used in NixOS.
      '';

      internal = true;
      type = types.attrsOf types.ints.u32;
    };

    ids.uids = lib.mkOption {
      description = ''
        The user IDs used in NixOS.
      '';

      internal = true;
      type = types.attrsOf types.ints.u32;
    };

  };

  config = {

    ids.gids = {
      activemq = 86;
      adm = 55;
      #notbit = 111; # unused
      aerospike = 111;
      # solr = 309; removed 2023-03-16
      alerta = 310;
      amule = 90;
      aria2 = 277;
      asterisk = 192;
      # bitlbee = 9; # removed 2021-10-05 #139765
      #avahi = 10; # removed 2019-05-22
      #nagios = 11; # unused
      atd = 12;
      audio = 17;
      automatic-timezoned = 326;
      bacula = 81;
      bepasty = 215;
      bosun = 161;
      caddy = 239;
      #kibana = 211;
      # xtreemfs = 212; # dropped in 26.05
      calibre-server = 213;
      cassandra = 300;
      cdrom = 24;
      # monero = 287; # dynamically allocated as of 2021-05-08
      ceph = 288;
      # rmilter = 226; # unused, removed 2019-08-22
      cfdyndns = 227;
      #hydron = 298; # removed 2024-08-03
      cfssl = 299;
      chrony = 61;
      clamav = 51;
      clickhouse = 278;
      clock = 327;
      cockroachdb = 313;
      couchdb = 106;
      datadog = 76;
      # ddclient = 30; # converted to DynamicUser = true
      davfs2 = 31;
      #almir = 82; # removed 2018-03-25, the almir package was removed in 30291227f2411abaca097773eedb49b8f259e297 during 2017-08
      deluge = 83;
      dialout = 27;
      #logcheck = 103; # unused
      #nix-ssh = 104; # unused
      dictd = 105;
      disk = 6;
      disnix = 33;
      distcc = 321;
      docker = 131;
      dovecot = 15;
      #rtkit = 45; # unused
      dovecot2 = 46;
      dovenull2 = 47;
      dspam = 222;
      duplicati = 289;
      ejabberd = 219;
      elasticsearch = 92;
      #panamax = 170; # unused
      exim = 172;
      # couchpotato = 267; # unused, removed 2022-01-01
      # gogs = 268; # unused, removed in 2024-10-12
      #kresd = 270; # switched to "knot-resolver" with dynamic ID
      #rpc = 271; # unused
      #geoip = 272; # unused
      fcron = 273;
      #tcpcryptd = 93; # unused
      firebird = 95;
      floppy = 18;
      foundationdb = 118;
      fourstore = 42;
      fourstorehttp = 43;
      freenet = 79;
      #vsftpd = 7; # dynamically allocated as of 2021-09-14
      ftp = 8;
      gdm = 132;
      #cups = 36; # unused
      #foldingathome = 37; # unused
      #sabnzd = 38; # unused
      #kdm = 39; # unused, even before 17.03
      #ghostone = 40; # dropped in 18.03
      git = 41;
      gitit = 202;
      #peerflix = 163; # unused
      #chronos = 164; # unused
      gitlab = 165;
      #telegraf = 256; # unused
      gitlab-runner = 257;
      gitolite = 127;
      gnunet = 87;
      #smokeping = 250;# dynamically allocated as of 2021-09-03
      gocd-agent = 251;
      gocd-server = 252;
      gpsd = 23;
      graphite = 68;
      hadoop = 297;
      haldaemon = 5;
      hass = 286;
      #etcd = 156; # unused
      hbase = 158;
      hdfs = 295;
      headphones = 266;
      hqplayer = 319;
      hydra = 122;
      i2p = 190;
      i2pd = 150;
      #rdnssd = 188; # unused
      ihaskell = 189;
      # stanchion = 262; # unused, removed 2020-10-14
      # riak-cs = 263; # unused, removed 2020-10-14
      infinoted = 264;
      influxdb = 125;
      #fleet = 173; # unused
      input = 174;
      iodined = 66;
      ipfs = 261;
      ircd = 80;
      jackett = 276;
      #searx = 107; # dynamically allocated as of 2020-10-27
      #kippo = 108; # removed 2021-10-07, the kippo package was removed in 1b213f321cdbfcf868b96fd9959c24207ce1b66a during 2021-04
      jenkins = 109;
      kanboard = 281;
      kapacitor = 308;
      keys = 96;
      kmem = 2;
      # pykms = 282; # DynamicUser = true
      kodi = 283;
      kubernetes = 162;
      kvm = 302; # default udev rules from systemd requires these
      lambdabot = 191;
      # hound = 259; # unused, removed 2023-11-21
      leaps = 260;
      libvirtd = 67;
      lidarr = 306;
      lightdm = 78;
      lighttpd = 77;
      liquidsoap = 155;
      lirc = 305;
      localtimed = 325;
      lp = 20;
      mapred = 296;
      mathics = 218;
      # gale = 223; removed 2021-06-10
      matrix-synapse = 224;
      mattermost = 254;
      #redis = 181; # unused, removed 2018-01-03
      #unifi = 183; # unused
      #uptimed = 184; # unused
      #zope2 = 185; # unused
      #ripple-data-api = 186; #unused
      mediatomb = 187;
      messagebus = 4; # D-Bus
      # restya-board = 284; # removed 2024-01-22
      mighttpd2 = 285;
      minetest = 311;
      minidlna = 91;
      minio = 280;
      mlmmj = 135;
      monetdb = 290;
      moonraker = 320;
      # polipo = 129; removed 2025-05-18
      mopidy = 130;
      mosquitto = 246;
      # prayer = 49; # dropped in 23.11
      mpd = 50;
      #haproxy = 97; # dynamically allocated as of 2020-03-11
      #mongodb = 98; # unused
      #openldap = 99; # dynamically allocated as of PR#94610
      munin = 102;
      #ripped = 116; # unused
      murmur = 117;
      mysql = 84;
      # riak = 205;#unused, removed 2022-06-22
      #shout = 206; #unused
      #gateone = 207; #removed 2025-08-21
      namecoin = 208;
      networkmanager = 57;
      newrelic = 119;
      nginx = 60;
      nixbld = 30000;
      # pumpio = 216; # unused, removed 2018-02-24
      nm-openvpn = 217;
      nogroup = 65534;
      nsd = 126;
      nslcd = 58;
      nylon = 168;
      nzbget = 245;
      octoprint = 230;
      oidentd = 88;
      # When adding a gid, make sure it doesn't match an existing
      # uid. Users and groups with the same name should have equal
      # uids and gids.
      #
      # !!! Don't use gids above "399"! !!!
      #
      # The reason behind this restriction is that, NixOS by default allocates
      # system user UIDs/GIDs in the range of `400..999`. System users/groups
      # created using command like `useradd` will have UID and GID in this range[1].
      #
      # If a newly added ID goes beyond "399", it may conflict with existing
      # system user or group of the same id in someone else's NixOS.
      # This could break their system and make that person upset for a whole day.
      #
      # Sidenote: the default is defined in `shadow` module[2], and the relevant change
      # was made way back in 2014[3].
      #
      # [1]: https://man7.org/linux/man-pages/man5/login.defs.5.html#:~:text=SYS_UID_MAX%20(number)%2C%20SYS_UID_MIN%20(number)
      # [2]: <nixos/modules/programs/shadow.nix>
      # [3]: https://github.com/NixOS/nixpkgs/commit/0e23a175de3687df8232fe118cbe87f04228ff28
      # For exceptional cases where you really need a gid above 399, leave a
      # comment stating why.
      #
      # Also, avoid the following GID ranges:
      #
      #  1000 - 29999: user accounts (see ../config/update-users-groups.pl)
      # 30000 - 31000: nixbld users (the upper limit is arbitrarily chosen)
      # 61184 - 65519: systemd DynamicUser (see systemd.exec(5))
      #         65535: the error return sentinel value when uid_t was 16 bits
      #
      # 100000 - 6653600: subgid allocated for user namespaces
      #                   (see ../config/update-users-groups.pl)
      #       4294967294: unauthenticated user in some NFS implementations
      #       4294967295: error return sentinel value
      #
      # References:
      # https://www.debian.org/doc/debian-policy/ch-opersys.html#uid-and-gid-classes
      onepassword = 31001; # 1Password requires that its GID be larger than 1000
      onepassword-cli = 31002; # 1Password requires that its GID be larger than 1000
      opendkim = 221;
      opentsdb = 159;
      openvpn = 292;
      osgi = 34;
      paperless = 315;
      pdnsd = 229;
      pipewire = 323;
      plex = 193;
      postdrop = 14;
      postfix = 13;
      postgres = 71;
      postgrey = 258;
      postsrsd = 220;
      proc = 21;
      prometheus = 255;
      #seeks = 148; # removed 2020-06-21
      prosody = 149;
      pulseaudio = 22; # must match `pulseaudio' UID
      qemu-libvirtd = 301;
      quassel = 89;
      rabbitmq = 85;
      radarr = 275;
      #yandexdisk = 143; # unused
      # mxisd = 144; # removed 2024-07-10
      #consul = 145; # unused
      #mailpile = 146; # removed 2022-01-12
      redmine = 147;
      render = 303; # default udev rules from systemd requires these
      restic = 291;
      #neo4j = 136; # unused
      riemann = 137;
      riemanndash = 138;
      riemanntools = 203;
      root = 0;
      rslsync = 279;
      rspamd = 225;
      rss2email = 312;
      rstudio-server = 324;
      scanner = 59;
      scollector = 160;
      sddm = 175;
      sgx = 304; # default udev rules from systemd requires these
      shadow = 318;
      sickbeard = 265;
      #dhcpcd = 133; # unused
      siproxd = 134;
      slurm = 307;
      smbguest = 74; # unused
      smtpd = 63;
      smtpq = 64;
      # factorio = 241; # unused
      # emby = 242; # unused, removed 2019-05-01
      sniproxy = 244;
      sonarr = 274;
      spamd = 56;
      spiped = 123;
      starbound = 120;
      subsonic = 204;
      supybot = 65;
      #radicale = 234;# dynamically allocated as of 2021-09-03
      syncthing = 237;
      systemd-journal = 62;
      systemd-journal-gateway = 110;
      systemd-network = 152;
      systemd-resolve = 153;
      systemd-timesync = 154;
      tape = 25;
      taskd = 240;
      teamspeak = 124;
      terraria = 253;
      tomcat = 16;
      tor = 35;
      #statsd = 69; # removed 2018-11-14
      transmission = 70;
      tty = 3;
      #toxvpn = 247; # unused
      #squeezelite = 248; #unused
      turnserver = 249;
      #radvd = 139; # unused
      #zookeeper = 140; # unused
      #dnsmasq = 141; # unused
      uhub = 142;
      users = 100;
      #polkituser = 28; # currently unused, polkitd doesn't need a group
      utmp = 29;
      uucp = 19;
      #sabnzbd = 194; # dropped in 26.05
      #grafana = 196; #unused
      #skydns = 197; #unused
      # ripple-rest = 198; # unused, removed 2017-08-12
      #nix-serve = 199; #unused
      #tvheadend = 200; #unused
      uwsgi = 201;
      varnish = 75;
      #ngircd = 112; # unused
      #btsync = 113; # unused
      #minecraft = 114; # unused
      vault = 115;
      vboxsf = 73;
      vboxusers = 72;
      video = 26;
      virtuoso = 44;
      webdav = 322;
      wheel = 1;
      #fprot = 52; # unused
      #bind = 53; # unused
      wwwrun = 54;
      # meguca = 293; # removed 2020-08-21
      yarn = 294;
      #tss = 176; #dynamically allocateda as of 2021-09-20
      #memcached = 177; # unused, removed 2018-01-03
      #ntp = 179; # unused
      zabbix = 180;
      #mailman = 316;  # removed 2019-08-30
      zigbee2mqtt = 317;
      znc = 128;
      zoneminder = 314;
    };

    ids.uids = {
      activemq = 86;
      #notbit = 111; # unused
      aerospike = 111;
      # solr = 309; removed 2023-03-16
      alerta = 310;
      amule = 90;
      aria2 = 277;
      asterisk = 192;
      atd = 12;
      automatic-timezoned = 326;
      avahi-autoipd = 231;
      bacula = 81;
      #heapster = 214; #dynamically allocated as of 2021-09-17
      bepasty = 215;
      bosun = 161;
      caddy = 239;
      # tox-bootstrapd = 166; removed 2021-09-15
      cadvisor = 167;
      #lxd = 210; # unused
      #kibana = 211;# dynamically allocated as of 2021-09-03
      # xtreemfs = 212; # dropped in 26.05
      calibre-server = 213;
      cassandra = 300;
      #monero = 287; # dynamically allocated as of 2021-05-08
      ceph = 288;
      # rmilter = 226; # unused, removed 2019-08-22
      cfdyndns = 227;
      #hydron = 298; # removed 2024-08-03
      cfssl = 299;
      chrony = 61;
      clamav = 51;
      clickhouse = 278;
      cockroachdb = 313;
      couchdb = 106;
      cups = 36;
      datadog = 76;
      #utmp = 29; # unused
      # ddclient = 30; # converted to DynamicUser = true
      davfs2 = 31;
      #almir = 82; # removed 2018-03-25, the almir package was removed in 30291227f2411abaca097773eedb49b8f259e297 during 2017-08
      deluge = 83;
      #logcheck = 103; #dynamically allocated as of 2021-09-17
      #nix-ssh = 104; #dynamically allocated as of 2021-09-03
      dictd = 105;
      disnix = 33;
      distcc = 321;
      #postdrop = 14; # unused
      dovecot = 15;
      #fourstore = 42; # dropped in 20.03
      #fourstorehttp = 43; # dropped in 20.03
      #virtuoso = 44;  dropped module
      #rtkit = 45; # dynamically allocated 2021-09-03
      dovecot2 = 46;
      dovenull2 = 47;
      dspam = 222;
      duplicati = 289;
      # mathics = 218; # unused, removed 2020-08-15
      ejabberd = 219;
      elasticsearch = 92;
      #apache-kafka = 169;# dynamically allocated as of 2021-09-03
      #panamax = 170; # unused
      exim = 172;
      #geoip = 272; # new module uses DynamicUser
      fcron = 273;
      firebird = 95;
      foldingathome = 37;
      foundationdb = 118;
      freenet = 79;
      #disk = 6; # unused
      #vsftpd = 7; # dynamically allocated ass of 2021-09-14
      ftp = 8;
      #docker = 131; # unused
      gdm = 132;
      #sabnzbd = 38; # dropped in 26.05
      #kdm = 39; # dropped in 17.03
      #ghostone = 40; # dropped in 18.03
      git = 41;
      #chronos = 164; # removed 2020-08-15
      gitlab = 165;
      gitlab-runner = 257;
      gitolite = 127;
      gnunet = 87;
      #smokeping = 250;# dynamically allocated as of 2021-09-03
      gocd-agent = 251;
      gocd-server = 252;
      gpsd = 23;
      grafana = 196;
      #libvirtd = 67; # unused
      graphite = 68;
      hadoop = 297;
      haldaemon = 5;
      hass = 286;
      #etcd = 156;# dynamically allocated as of 2021-09-03
      hbase = 158;
      hdfs = 295;
      headphones = 266;
      # shadow = 318; # unused
      hqplayer = 319;
      hydra = 122;
      #radicale = 234;# dynamically allocated as of 2021-09-03
      hydra-queue-runner = 235;
      hydra-www = 236;
      i2p = 190;
      i2pd = 150;
      #rdnssd = 188; #dynamically allocated as of 2021-09-18
      ihaskell = 189;
      # stanchion = 262; # unused, removed 2020-10-14
      # riak-cs = 263; # unused, removed 2020-10-14
      infinoted = 264;
      influxdb = 125;
      iodined = 66;
      ipfs = 261;
      ircd = 80;
      jackett = 276;
      #searx = 107; # dynamically allocated as of 2020-10-27
      #kippo = 108; # removed 2021-10-07, the kippo package was removed in 1b213f321cdbfcf868b96fd9959c24207ce1b66a during 2021-04
      jenkins = 109;
      kanboard = 281;
      kapacitor = 308;
      # pykms = 282; # DynamicUser = true
      kodi = 283;
      kubernetes = 162;
      lambdabot = 191;
      # hound = 259; # unused, removed 2023-11-21
      leaps = 260;
      lidarr = 306;
      lightdm = 78;
      lighttpd = 77;
      liquidsoap = 155;
      # kvm = 302; # unused
      # render = 303; # unused
      # zeronet = 304; # removed 2019-01-03
      lirc = 305;
      localtimed = 325;
      mapred = 296;
      # gale = 223; removed 2021-06-10
      matrix-synapse = 224;
      mattermost = 254;
      #zope2 = 185; # dynamically allocated as of 2021-09-18
      #ripple-data-api = 186; dynamically allocated as of 2021-09-17
      mediatomb = 187;
      #wheel = 1; # unused
      #kmem = 2; # unused
      #tty = 3; # unused
      messagebus = 4; # D-Bus
      # restya-board = 284; # removed 2024-01-22
      mighttpd2 = 285;
      minetest = 311;
      minidlna = 91;
      minio = 280;
      # nntp-proxy = 232; #dynamically allocated as of 2021-09-17
      mjpg-streamer = 233;
      mlmmj = 135;
      monetdb = 290;
      moonraker = 320;
      # polipo = 129; removed 2025-05-18
      mopidy = 130;
      mosquitto = 246;
      # prayer = 49; # dropped in 23.11
      mpd = 50;
      #keys = 96; # unused
      #haproxy = 97; # dynamically allocated as of 2020-03-11
      #mongodb = 98; #dynamically allocated as of 2021-09-03
      #openldap = 99; # dynamically allocated as of PR#94610
      #users = 100; # unused
      # cgminer = 101; #dynamically allocated as of 2021-09-17
      munin = 102;
      # rippled = 116; #dynamically allocated as of 2021-09-18
      murmur = 117;
      mysql = 84;
      # bitlbee = 9; # removed 2021-10-05 #139765
      #avahi = 10; # removed 2019-05-22
      nagios = 11;
      # riak = 205; # unused, remove 2022-07-22
      #shout = 206; # dynamically allocated as of 2021-09-18, module removed 2024-10-19
      #gateone = 207; # removed 2025-08-21
      namecoin = 208;
      newrelic = 119;
      nginx = 60;
      # When adding a uid, make sure it doesn't match an existing gid.
      #
      # !!! Don't use uids above "399"! !!!
      #
      # The reason behind this restriction is that, NixOS by default allocates
      # system user UIDs/GIDs in the range of `400..999`. System users/groups
      # created using command like `useradd` will have UID and GID in this range[1].
      #
      # If a newly added ID goes beyond "399", it may conflict with existing
      # system user or group of the same id in someone else's NixOS.
      # This could break their system and make that person upset for a whole day.
      #
      # Sidenote: the default is defined in `shadow` module[2], and the relevant change
      # was made way back in 2014[3].
      #
      # [1]: https://man7.org/linux/man-pages/man5/login.defs.5.html#:~:text=SYS_UID_MAX%20(number)%2C%20SYS_UID_MIN%20(number)
      # [2]: <nixos/modules/programs/shadow.nix>
      # [3]: https://github.com/NixOS/nixpkgs/commit/0e23a175de3687df8232fe118cbe87f04228ff28
      nixbld = 30000; # start of range of uids
      # pumpio = 216; # unused, removed 2018-02-24
      nm-openvpn = 217;
      nobody = 65534;
      nsd = 126;
      #networkmanager = 57; # unused
      nslcd = 58;
      nylon = 168;
      nzbget = 245;
      octoprint = 230;
      oidentd = 88;
      opendkim = 221;
      opentsdb = 159;
      openvpn = 292;
      osgi = 34;
      paperless = 315;
      # gammu-smsd = 228; #dynamically allocated as of 2021-09-17
      pdnsd = 229;
      peerflix = 163;
      pipewire = 323;
      plex = 193;
      plexpy = 195;
      #cdrom = 24; # unused
      #tape = 25; # unused
      #video = 26; # unused
      #dialout = 27; # unused
      polkituser = 28;
      postfix = 13;
      postgres = 71;
      postgrey = 258;
      postsrsd = 220;
      prometheus = 255;
      #seeks = 148; # removed 2020-06-21
      prosody = 149;
      #lp = 20; # unused
      #proc = 21; # unused
      pulseaudio = 22; # must match `pulseaudio' GID
      qemu-libvirtd = 301;
      quassel = 89;
      rabbitmq = 85;
      radarr = 275;
      # mxisd = 144; # removed 2024-07-10
      #consul = 145;# dynamically allocated as of 2021-09-03
      #mailpile = 146; # removed 2022-01-12
      redmine = 147;
      restic = 291;
      #neo4j = 136;# dynamically allocated as of 2021-09-03
      riemann = 137;
      riemanndash = 138;
      # gitit = 202; # unused, module was removed 2023-04-03
      riemanntools = 203;
      root = 0;
      # couchpotato = 267; # unused, removed 2022-01-01
      # gogs = 268; # unused, removed in 2024-10-12
      #pdns-recursor = 269; # dynamically allocated as of 2020-20-18
      #kresd = 270; # switched to "knot-resolver" with dynamic ID
      rpc = 271;
      rslsync = 279;
      rspamd = 225;
      rss2email = 312;
      rstudio-server = 324;
      scanner = 59;
      scollector = 160;
      #fleet = 173; # unused
      #input = 174; # unused
      sddm = 175;
      sickbeard = 265;
      #dhcpd = 133; # dynamically allocated as of 2021-09-03
      siproxd = 134;
      skydns = 197;
      slurm = 307;
      #vboxusers = 72; # unused
      #vboxsf = 73; # unused
      smbguest = 74; # unused
      #systemd-journal = 62; # unused
      smtpd = 63;
      smtpq = 64;
      # factorio = 241; # DynamicUser = true
      # emby = 242; # unused, removed 2019-05-01
      #graylog = 243;# dynamically allocated as of 2021-09-03
      sniproxy = 244;
      sonarr = 274;
      #adm = 55; # unused
      spamd = 56;
      spiped = 123;
      starbound = 120;
      subsonic = 204;
      supybot = 65;
      syncthing = 237;
      systemd-coredump = 151;
      systemd-journal-gateway = 110;
      systemd-network = 152;
      systemd-resolve = 153;
      systemd-timesync = 154;
      taskd = 240;
      tcpcryptd = 93; # tcpcryptd uses a hard-coded uid. We patch it in Nixpkgs to match this choice.
      teamspeak = 124;
      telegraf = 256;
      terraria = 253;
      tomcat = 16;
      tor = 35;
      #statsd = 69; # removed 2018-11-14
      transmission = 70;
      #toxvpn = 247; # dynamically allocated as of 2021-09-18
      # squeezelite = 248; # DynamicUser = true
      turnserver = 249;
      #redis = 181; removed 2018-01-03
      #unifi = 183; dynamically allocated as of 2021-09-17
      uptimed = 184;
      #audio = 17; # unused
      #floppy = 18; # unused
      uucp = 19;
      # ripple-rest = 198; # unused, removed 2017-08-12
      # nix-serve = 199; # unused, removed 2020-12-12
      #tvheadend = 200; # dynamically allocated as of 2021-09-18
      uwsgi = 201;
      varnish = 75;
      #ngircd = 112; #dynamically allocated as of 2021-09-03
      #btsync = 113; # unused
      #minecraft = 114; #dynamically allocated as of 2021-09-03
      vault = 115;
      webdav = 322;
      #fprot = 52; # unused
      # bind = 53; #dynamically allocated as of 2021-09-03
      wwwrun = 54;
      #radvd = 139;# dynamically allocated as of 2021-09-03
      #zookeeper = 140;# dynamically allocated as of 2021-09-03
      #dnsmasq = 141;# dynamically allocated as of 2021-09-03
      #uhub = 142; # unused
      yandexdisk = 143;
      # meguca = 293; # removed 2020-08-21
      yarn = 294;
      #tss = 176; # dynamically allocated as of 2021-09-17
      #memcached = 177; removed 2018-01-03
      #ntp = 179; # dynamically allocated as of 2021-09-17
      zabbix = 180;
      #mailman = 316;  # removed 2019-08-30
      zigbee2mqtt = 317;
      znc = 128;
      zoneminder = 314;
    };

  };

}
