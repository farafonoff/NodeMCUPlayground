function car_run()
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
        print(data)
        if data ~= "discover" then
            state = data
        else
            print(string.format("discover: %s:%d", ip, port))    
            
        end 
        udpSocket:send(port, ip, data);
        --s:send(port, ip, "echo: " .. data)
    end)
    port, ip = udpSocket:getaddr()
    print(string.format("local UDP socket address / port: %s:%d", ip, port))
end

print('HEAP:',node.heap())
ap_ssid,ap_pass = "esp8266","optanex14";

if (file.open('wificonf') == true)then
   ssid = string.gsub(file.readline(), "\n", "");
   pass = string.gsub(file.readline(), "\n", "");
   file.close();
end

wifi.setmode(wifi.STATION)
--wifi.sta.config {ssid=ssid,pwd=pass}
--wifi.sta.autoconnect(1);
known_fi = {}
known_fi["netis_24"]="optanex14"
selected_config = nil

function run_softap()
        print("hotspot not found, running softap")
        wifi.setmode(wifi.SOFTAP)
        wifi.ap.config{ssid=ap_ssid, pwd=ap_pass}
        tmr.alarm(0,200,0,car_run)
end

wifi.sta.getap(1, function(t)
    print("\n\t\t\tSSID\t\t\t\t\tBSSID\t\t\t  RSSI\t\tAUTHMODE\t\tCHANNEL")
    for bssid,v in pairs(t) do
        local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
        print(string.format("%32s",ssid).."\t"..bssid.."\t  "..rssi.."\t\t"..authmode.."\t\t\t"..channel)
        if known_fi[ssid] then
            selected_config = {ssid=ssid,pwd=known_fi[ssid]}
        end
    end
    if selected_config then
        wifi.sta.autoconnect(1);
        wifi.sta.config(selected_config)
        tmr.alarm(0,500,0,run)
    else
        tmr.alarm(0,200,0,run_softap)
    end
end)

--uart.setup(1, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)
--uart.write(1, "Hello world")
--print('IP:',wifi.sta.getip());
--print('MAC:',wifi.sta.getmac());
