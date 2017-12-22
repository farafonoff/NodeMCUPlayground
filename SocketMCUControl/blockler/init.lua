rpin = 1
gpin = 2
bpin = 5
function initGPIO()
    --1,2EN     D1 GPIO5
    --3,4EN     D2 GPIO4
    --1A  ~2A   D3 GPIO0
    --3A  ~4A   D4 GPIO2
    
    gpio.mode(0,gpio.OUTPUT);--LED Light on
    gpio.write(0,gpio.LOW);
    
    gpio.mode(rpin,gpio.OUTPUT);gpio.write(rpin,gpio.LOW);
    gpio.mode(gpin,gpio.OUTPUT);gpio.write(gpin,gpio.LOW);
    gpio.mode(bpin,gpio.OUTPUT);gpio.write(bpin,gpio.LOW);
end

initGPIO();


function continue_run(cor)
    local res, delay = coroutine.resume(cor)
    print(res, delay,coroutine.status(cor))
    if (res == false or delay == nil) then
        return
    end
    if (delay>0) then
        local mytimer = tmr.create()
        mytimer:register(delay, tmr.ALARM_SINGLE, 
            function (t)
                t:unregister()
                continue_run(cor)
            end)
        mytimer:start()
    else
        node.task.post(0, function()
            continue_run(cor)            
        end)    
    end
end

function try_run() 
    f = loadfile('input.lua')
    co = coroutine.create(f)
    continue_run(co)            
end

function car_run()
    state=""
    initGPIO();

    function setColor(state)
        r,l,c = string.match(state, '_R(%d+)G(%d+)B(%d+)|');
        r = tonumber(r);
        g = tonumber(g);
        b = tonumber(b);
    end
    
    
    tmr.alarm(0,500, tmr.ALARM_AUTO, function() 
        if string.len(state)>0 then 
            setMotors(state);
        end
    end)
    
    print('HEAP:',node.heap())
    
    udpSocket = net.createUDPSocket()
    udpSocket:listen(1235)
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
