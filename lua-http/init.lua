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
--print('IP:',wifi.sta.getip());
--print('MAC:',wifi.sta.getmac());

led1 = 0
led2 = 1
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
restart=0;

gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);


t=0
tmr.alarm(0,1000, 1, function() t=t+1 if t>999 then t=0 end end)

print('HEAP:',node.heap())

function api_gpio(param)
    print(param)
    local _,_,port,value=string.find(param, "([0-9]+):(t?f?).*");
    print(port)
    port = tonumber(port);
    print(port)
    gpio.write(port, value == "t" and gpio.HIGH or gpio.LOW)
end

function api(target, param)
    if target == "gpio" then api_gpio(param) end
end

function sendfile(conn, file_name)
    local seek_ptr = 0
    conn:on("sent",
        function(conn)
            file.open(file_name)
            print("Open file "..file_name)
            if (seek_ptr == file.seek("end")) then
                conn:close()
            else
                file.seek("set", seek_ptr)
                conn:send(file.read())
                seek_ptr = file.seek()
                print("Send part of file "..file_name.." Seek is "..seek_ptr)
            end
            file.close()
            print("Close file "..file_name)
        end
    )
end

function sendheader(conn, respcode, response)
    conn:send('HTTP/1.1 '..respcode..' OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n' .. response);
    if repsponse ~= "" then
        conn:on("sent", function(conn) 
                print("sent response" .. response)
                conn:close()
            end)
    end
end

srv=net.createServer(net.TCP, 1000)
print('HEAP:',node.heap())
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
            local _, _, method, path = string.find(request, "([A-Z]+) /(.*) HTTP");
            print(path)
            local _, _, apitarget, param = string.find(path, "^api/([a-z]+)/(.*)$");
            if (apitarget) then
                api(apitarget, param) 
                sendheader(conn, "200", "done");
            else
                if path == "" then path = "led.html" end;
                if file.exists(path) then
                    sendheader(conn, "200", "");
                    sendfile(conn, path);
                else
                    sendheader(conn, "404", "not found");
                end
            end
        --conn:on("sent",function(conn) conn:close() end)
        collectgarbage();
    end)
end)
