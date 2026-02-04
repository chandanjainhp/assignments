c = get_config()  #noqa

# Password: openoa
# Hashed using: from jupyter_server.auth import passwd; passwd('openoa')
c.ServerApp.password = 'argon2:$argon2id$v=19$m=10240,t=10,p=8$pi93QW/fyz16DawrQE+I8A$366WmSuuoXScFD1tMEeSvOpUytsGawkAmToaUIAx09hg'

c.ServerApp.ip = '0.0.0.0'
c.ServerApp.open_browser = False
c.ServerApp.allow_root = True
