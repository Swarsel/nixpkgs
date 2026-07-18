{ icinga2 }:
icinga2.override {
  nameSuffix = "-agent";
  withIcingadb = false;
  withMysql = false;
  withNotification = false;
  withOtel = false;
  withPerfdata = false;
}
