print('HEAP:',node.heap())
ssid,pass = "esp8266","optanex14";

if (file.open('wificonf') == true)then
   ssid = string.gsub(file.readline(), "\n", "");
   pass = string.gsub(file.readline(), "\n", "");
   file.close();
end

--wifi.setmode(wifi.STATION)
--wifi.sta.config {ssid=ssid,pwd=pass}
--wifi.sta.autoconnect(1);
wifi.setmode(wifi.SOFTAP)
wifi.ap.config{ssid=ssid, pwd=pass}

--uart.setup(1, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)
--uart.write(1, "Hello world")
--print('IP:',wifi.sta.getip());
--print('MAC:',wifi.sta.getmac());

led1 = 0
led2 = 1
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
restart=0;

gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);

state=""

tmr.alarm(0,10, tmr.ALARM_AUTO, function() 
    if string.len(state)>0 then 
        print(state)
    end
end)

print('HEAP:',node.heap())

function api_gpio(param)
    gpio.write(port, value == "t" and gpio.HIGH or gpio.LOW)
end

function process(type, data)
    for lop=1,string.len(data) do
        gp = string.byte(data, lop)
        print(string.format("%d on port %d", type, gp))
        if (type == 1) then
            gpio.write(gp, gpio.HIGH)        
        end
        if (type == 2) then
            gpio.write(gp, gpio.LOW)
        end        
    end
end

udpSocket = net.createUDPSocket()
udpSocket:listen(1234)
udpSocket:on("receive", function(s, data, port, ip)
    --print(string.format("received '%d' from %s:%d", string.byte(data, 1), ip, port))
    --process(string.byte(data, 1), string.sub(data, 2))
    state = data
    print(state)
    udpSocket:send(port, ip, state);
    --s:send(port, ip, "echo: " .. data)
end)
port, ip = udpSocket:getaddr()
print(string.format("local UDP socket address / port: %s:%d", ip, port))
