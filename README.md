# Auml CAN packet dissector for Wireshark

Dissector for Auml CAN packets in wireshark

The CAN protocol is defined by [Auml Home Automation](http://projekt.auml.se/)

To use the dissector, make sure the can bus is available thorugh SocketCan,
see [can_proxy](https://www.github.com/ETAChalmers/can_proxy)

Use wireshark terminal client tshark, and the simple loader auml.lua:

```
tshark -i vcan0 -X lua_script:auml.lua
```

