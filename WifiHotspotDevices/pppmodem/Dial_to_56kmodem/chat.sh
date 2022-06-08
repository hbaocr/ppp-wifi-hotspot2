#!/bin/sh
#
# This is part 2 of the ppp-on script. It will perform the connection
# protocol for the desired connection.
#
#/usr/sbin/chat -v  '' ATZ OK 'ATQ0 V1 E1 S0=0 S2=128 &C1 &D2 +FCLASS=0' OK ATD$

#!/bin/sh
#
# This is part 2 of the ppp-on script. It will perform the connection
# protocol for the desired connection.
#
/usr/sbin/chat  -v                                       \
        TIMEOUT         3                               \
        ABORT           '\nBUSY\r'                      \
        ABORT           '\nNO ANSWER\r'                 \
        ABORT           '\nRINGING\r\n\r\nRINGING\r'    \
        ABORT           '\nNO CARRIER\r'                \
        ''              "\rATQ0 V1 E0 S0=0 S2=128 &C1 &D2 +FCLASS=0" \
        TIMEOUT         240                             \
        OK              ATD1089                         \
        ONECT           '' \
        ogin: dream                                \
        ssword: dreamcast
