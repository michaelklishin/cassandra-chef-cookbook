# Restart cassandra on failure conditions by default
# Check out the link below for the list of possible values and their meaning:
# https://www.freedesktop.org/software/systemd/man/systemd.service.html#Restart=
default['cassandra']['systemd']['restart_condition'] = 'on-failure'
