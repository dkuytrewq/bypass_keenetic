token = 'MyBotFatherToken'  # ключ api бота
usernames = ['MySuperLogin']  # Ваш логин в телеграмме без @, не бота. Логин именно Вашей учетной записи в ТГ.

routerip = '192.168.1.1'  # ip роутера

# список vpn для выборочной маршрутизации (то что доступно из интерфейса роутера)
vpn_allowed="IKE|SSTP|OpenVPN|Wireguard|L2TP"

# следующие настройки могут быть оставлены по умолчанию, но можно будет что-то поменять
localportsh = '1082'  # локальный порт для shadowsocks
localportvless = '10810'  # локальный порт для vless
dnsovertlsport = '40500'  # можно посмотреть номер порта командой "cat /tmp/ndnproxymain.stat"
dnsoverhttpsport = '40508'  # можно посмотреть номер порта командой "cat /tmp/ndnproxymain.stat"