function initGPIO()
    --1,2EN     D1 GPIO5
    --3,4EN     D2 GPIO4
    --1A  ~2A   D3 GPIO0
    --3A  ~4A   D4 GPIO2
    
    gpio.mode(0,gpio.OUTPUT);--LED Light on
    gpio.write(0,gpio.LOW);
    
    gpio.mode(1,gpio.OUTPUT);gpio.write(1,gpio.LOW);
    gpio.mode(2,gpio.OUTPUT);gpio.write(2,gpio.LOW);
    
    gpio.mode(3,gpio.OUTPUT);gpio.write(3,gpio.HIGH);
    gpio.mode(4,gpio.OUTPUT);gpio.write(4,gpio.HIGH);
    
    pwm.setup(1,1000,1023);--PWM 1KHz, Duty 1023
    pwm.start(1);pwm.setduty(1,0);
    pwm.setup(2,1000,1023);
    pwm.start(2);pwm.setduty(2,0);       
end

initGPIO();


function car_run()
    state=""
    initGPIO();

    function controlMotor(pin, v)
        if (v<0) then
            gpio.write(pin, gpio.LOW);
            v = -v;
        else
            gpio.write(pin, gpio.HIGH);            
        end
        duty = math.floor((v/255)*1023);
        pwm.setduty(pin-2, duty)    
    end

    function setMotors(state)
        r,l,c = string.match(state, '_R(-?%d+)L(-?%d+)C(-?%d+)|');
        r = tonumber(r);
        l = tonumber(l);
        c = tonumber(c);
        controlMotor(3, r);
        controlMotor(4, l);
    end
    
    
    tmr.alarm(0,500, tmr.ALARM_AUTO, function() 
        if string.len(state)>0 then 
            setMotors(state);
        end
    end)
    
    print('HEAP:',node.heap())
    
    udpSocket = net.createUDPSocket()
    udpSocket:listen(1234)
    udpSocket:on("receive", function(s, data, port, ip)
        --print(string.format("received '%d' from %s:%d", string.byte(data, 1), ip, port))
        --process(string.byte(data, 1), string.sub(data, 2))
        if data ~= "discover" then
            state = data
            setMotors(state);
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
        tmr.alarm(0,500,0,car_run)
    else
        tmr.alarm(0,200,0,run_softap)
    end
end)

--uart.setup(1, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)
--uart.write(1, "Hello world")
--print('IP:',wifi.sta.getip());
--print('MAC:',wifi.sta.getmac());
