library buscocard.globals;

const String env = 'prod';
const String version = '1.2.4';
const String ipLocal = '192.168.0.47';

const String protocolo         = (env == 'dev') ? 'http://' : 'https://';
const String dominio           = (env == 'dev') ? '$ipLocal/dbzminfo/public_html/index.php' : 'dbzm.info';
const String dominioBase       = (env == 'dev') ? '$ipLocal/bcmxTds/public_html' : 'buscomex.com';
const String baseThumTds       = (env == 'dev') ? '$protocolo$dominioBase/thum_tds' : '$protocolo$dominioBase/thum_tds';
const String base              = '$protocolo$dominio';
const String baseTds           = '$protocolo$dominioBase/tds';
