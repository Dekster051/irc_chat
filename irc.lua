script_name("SampIrcClient")
script_author("Laine_prikol, BezlikiY, Deks051")
-- script_version('3.4')
require "luairc"

---------------------------------------------------------------------------------------------------
require 'moonloader'

imgui = require'imgui'
encoding         = require("encoding")
encoding.default = 'CP1251'
u8 = encoding.UTF8

chat = {}

window = imgui.ImBool(false)
buffer = imgui.ImBuffer(256)





---------------------------------------------------------------------------------------------------
--[[
require "lib.moonloader"
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local keys = require 'vkeys'
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = UTF8

update_stats = false

local script_vers = 1
local script_vers_text = "1.00"

local update_url = "https://raw.githubusercontent.com/Dekster051/irc_chat/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"  -- тут ссылку

local script_url = ""
local script_path = thisScript().path --]]
---------------------------------------------------------------------------------------------------




IRCLogs = {}
local ansi_decode={
  [128]='\208\130',[129]='\208\131',[130]='\226\128\154',[131]='\209\147',[132]='\226\128\158',[133]='\226\128\166',
  [134]='\226\128\160',[135]='\226\128\161',[136]='\226\130\172',[137]='\226\128\176',[138]='\208\137',[139]='\226\128\185',
  [140]='\208\138',[141]='\208\140',[142]='\208\139',[143]='\208\143',[144]='\209\146',[145]='\226\128\152',
  [146]='\226\128\153',[147]='\226\128\156',[148]='\226\128\157',[149]='\226\128\162',[150]='\226\128\147',[151]='\226\128\148',
  [152]='\194\152',[153]='\226\132\162',[154]='\209\153',[155]='\226\128\186',[156]='\209\154',[157]='\209\156',
  [158]='\209\155',[159]='\209\159',[160]='\194\160',[161]='\209\142',[162]='\209\158',[163]='\208\136',
  [164]='\194\164',[165]='\210\144',[166]='\194\166',[167]='\194\167',[168]='\208\129',[169]='\194\169',
  [170]='\208\132',[171]='\194\171',[172]='\194\172',[173]='\194\173',[174]='\194\174',[175]='\208\135',
  [176]='\194\176',[177]='\194\177',[178]='\208\134',[179]='\209\150',[180]='\210\145',[181]='\194\181',
  [182]='\194\182',[183]='\194\183',[184]='\209\145',[185]='\226\132\150',[186]='\209\148',[187]='\194\187',
  [188]='\209\152',[189]='\208\133',[190]='\209\149',[191]='\209\151'
}
local utf8_decode={
  [128]={[147]='\150',[148]='\151',[152]='\145',[153]='\146',[154]='\130',[156]='\147',[157]='\148',[158]='\132',[160]='\134',[161]='\135',[162]='\149',[166]='\133',[176]='\137',[185]='\139',[186]='\155'},
  [130]={[172]='\136'},
  [132]={[150]='\185',[162]='\153'},
  [194]={[152]='\152',[160]='\160',[164]='\164',[166]='\166',[167]='\167',[169]='\169',[171]='\171',[172]='\172',[173]='\173',[174]='\174',[176]='\176',[177]='\177',[181]='\181',[182]='\182',[183]='\183',[187]='\187'},
  [208]={[129]='\168',[130]='\128',[131]='\129',[132]='\170',[133]='\189',[134]='\178',[135]='\175',[136]='\163',[137]='\138',[138]='\140',[139]='\142',[140]='\141',[143]='\143',[144]='\192',[145]='\193',[146]='\194',[147]='\195',[148]='\196',
  [149]='\197',[150]='\198',[151]='\199',[152]='\200',[153]='\201',[154]='\202',[155]='\203',[156]='\204',[157]='\205',[158]='\206',[159]='\207',[160]='\208',[161]='\209',[162]='\210',[163]='\211',[164]='\212',[165]='\213',[166]='\214',
  [167]='\215',[168]='\216',[169]='\217',[170]='\218',[171]='\219',[172]='\220',[173]='\221',[174]='\222',[175]='\223',[176]='\224',[177]='\225',[178]='\226',[179]='\227',[180]='\228',[181]='\229',[182]='\230',[183]='\231',[184]='\232',
  [185]='\233',[186]='\234',[187]='\235',[188]='\236',[189]='\237',[190]='\238',[191]='\239'},
  [209]={[128]='\240',[129]='\241',[130]='\242',[131]='\243',[132]='\244',[133]='\245',[134]='\246',[135]='\247',[136]='\248',[137]='\249',[138]='\250',[139]='\251',[140]='\252',[141]='\253',[142]='\254',[143]='\255',[144]='\161',[145]='\184',
  [146]='\144',[147]='\131',[148]='\186',[149]='\190',[150]='\179',[151]='\191',[152]='\188',[153]='\154',[154]='\156',[155]='\158',[156]='\157',[158]='\162',[159]='\159'},[210]={[144]='\165',[145]='\180'}
}

local nmdc = {
  [36] = '$',
  [124] = '|',
}

function AnsiToUtf8(s)
  local r, b = ''
  for i = 1, s and s:len() or 0 do
    b = s:byte(i)
    if b < 128 then
      r = r..string.char(b)
    else
      if b > 239 then
        r = r..'\209'..string.char(b - 112)
      elseif b > 191 then
        r = r..'\208'..string.char(b - 48)
      elseif ansi_decode[b] then
        r = r..ansi_decode[b]
      else
        r = r..'_'
      end
    end
  end
  return r
end


function Utf8ToAnsi(s)
  local a, j, r, b = 0, 0, ''
  for i = 1, s and s:len() or 0 do
    b = s:byte(i)
    if b < 128 then
      if nmdc[b] then
        r = r..nmdc[b]
      else
        r = r..string.char(b)
      end
    elseif a == 2 then
      a, j = a - 1, b
    elseif a == 1 then
      if (utf8_decode[j] or {})[b] then
        a, r = a - 1, r..utf8_decode[j][b]
      end
    elseif b == 226 then
      a = 2
    elseif b == 194 or b == 208 or b == 209 or b == 210 then
      j, a = b, 1
    else
      r = r..'_'
    end
  end
  return r
end


require("config.SAMPIRC_Config") -- load configuration
DebugMode = false
local s = irc.new{nick = Nick}
connected = false
function GetState(var)
  if var then
  return "{00FF00}On"
  else
  return "{FF0000}Off"
  end
end


function secondThread()
  while not isSampfuncsLoaded() do
    wait(1000)
  end
  sampAddChatMessage("SampIrcClient {FFFFFF}запущен: {EE7878}/crc - {FFFFFF}главное меню", 0x33AA33)
  if AutoConnect then
    connected = true
  end
  sampRegisterChatCommand("crc", ircmenu)
  while true do
    wait(0)
    imgui.Process = window.v

    local res, but, _, input= sampHasDialogRespond(100)
    if res then
      if but == 1 then
        if #input > 0 or input ~= nil then
          ircsend(input)
          sampShowDialog(100,'send IRC msg', '', 'send', 'calcel', 1)
        elseif #input < 0 or input == nil then
          sampShowDialog(100,'send IRC msg', '{FF0000}error arg', 'send', 'calcel', 1)
        end
        end
    end

    local resultMain, buttonMain, listMain = sampHasDialogRespond(154)
    if resultMain == true then
      if buttonMain == 1 then
        if listMain == 0 then
          sampShowDialog(1289, "Input", "Nickname:", "Ok", "Exit", 1)
        end
        if listMain == 1 then
          sampShowDialog(1290, "Input", "Server:", "Ok", "Exit", 1)
        end
        if listMain == 2 then
          sampShowDialog(1291, "Input", "Channel name (With #):", "Ok", "Exit", 1)
        end
        if listMain == 3 then
          connected = true
        end
        if listMain == 4 then
          sampAddChatMessage("Перезагрузка скрипта...", 0xff0000)
          thisScript():reload()
        end
        if listMain == 5 then
        sampAddChatMessage("Изменено значение!", -1)
        irclogs = not irclogs
        end
        if listMain == 6 then
        sampAddChatMessage("Изменено значение!", -1)
        AutoConnect = not AutoConnect
        end
        if listMain == 7 then
          saveChanges()
          sampAddChatMessage("Настройки изменены!", 0x00ff00)
        end
        if listMain == 8 then
          sampShowDialog(1292, "Change value", "Enter 0 to off sound\nSound ID:", "Ok", "Exit", 1)
        end
        if listMain == 9 then
          sampShowDialog(1293, "Change value", "{FF0000}This option may cause performance problems \nIRC Latency:", "Ok", "Exit", 1)
        end
        if listMain == 10 then
        DebugMode = not DebugMode
        sampAddChatMessage("Режим отладки: "..GetState(DebugMode))
        end
      end
      saveChanges()
    end
    local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1289)
    if resultInput == true then
    saveChanges()
      if buttonInput == 1 then
        Nick = stringInput
		saveChanges()
          sampAddChatMessage("[IRC] {ffffff}Вы сменили ник на: {ff6600}" .. Nick, 0xFFFF00)
		  wait(500)
		  s:send("Nick %s", Nick)                     -- Смена ника
      else sampAddChatMessage("Вы нажали Выход", -1)
      end
    end
    local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1290)
    if resultInput == true then
      if buttonInput == 1 then
        Server = stringInput
        sampAddChatMessage("[IRC] {ffffff}Сервер: " .. Server, 0xFFFF00)
      else sampAddChatMessage("Вы нажали Выход", -1)
      end
    end
    local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1291)
    if resultInput == true then
      if buttonInput == 1 then
        Channel = stringInput
        saveChanges()
		sampAddChatMessage("[IRC] {ffffff}Вы сменили канал на: {C37BF2}" .. Channel, 0xFFFF00)    
		wait(500)
		s:join(Channel)                   -- смена канала
      else sampAddChatMessage("Вы нажали Выход", -1)
      end
    end
    local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1292)
    if resultInput == true then
      if buttonInput == 1 then
        MessageSound = stringInput
		saveChanges()
        sampAddChatMessage("[IRC] {ffffff}Новый звук сообщения: {FFFF00}" .. MessageSound, 0xFFFF00)
      else sampAddChatMessage("Вы нажали Выход", -1)
      end
    end
    local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1293)
    if resultInput == true then
      if buttonInput == 1 then
        IRCLatency = stringInput
		saveChanges()
        sampAddChatMessage("[IRC] {ffffff}Новый локальный пинг IRC: {FFFF00}" .. IRCLatency, 0xFFFF00)
      else sampAddChatMessage("Вы нажали Выход", -1)
      end
    end
	
	
  end
end


function saveChanges()
  file = io.open("moonloader/config/SAMPIRC_Config.lua", "w")
  StrforSave = string.format('Channel = "%s"\nServer = "%s"\nNick = "%s"\nirclogs = %s\nAutoConnect = %s\nMessageSound = %d\nIRCLatency = %d',Channel, Server, Nick, tostring(irclogs), tostring(AutoConnect), MessageSound, IRCLatency)
  file:write(StrforSave)
  file:close()
end


function main()
autoupdate("https://www.dropbox.com/home/moonloader_update?preview=update.json", '['..string.upper(thisScript().name)..']: ', "https://www.blast.hk/threads/133136/")
  while not isSampAvailable() do wait(100) end
    wait(1000)
    local thread1 = lua_thread.create(secondThread, false)
    while not isSampAvailable() or not connected do wait(100) end
	


    while not sampIsLocalPlayerSpawned() and not sampIsDialogActive() and not sampIsChatInputActive() do wait(100) end
	
  wait(2900)
  printStringNow('~b~WAIT,loading ~y~IRC~b~!',100)
  printStringNow('~b~WAIT,loading ~y~IRC~b~!',100)
  printStringNow('~b~WAIT,loading ~y~IRC~b~!',100)
  printStringNow('~b~WAIT,loading ~y~IRC~b~!',100)
  printStringNow('~b~WAIT,loading ~y~IRC~b~!',100)
  wait(100)
  	
      local sleep = require "socket".sleep
      sampRegisterChatCommand("cr", ircsend)
      sampRegisterChatCommand("cpm", ircquery)
      sampRegisterChatCommand("crr", ircraw)
	    sampRegisterChatCommand("cme", ircme)
	    sampRegisterChatCommand("crl", irclist)

      sampRegisterChatCommand("cri", function() window.v = not window.v end)
      sampRegisterChatCommand("crd", function() sampShowDialog(100,'send IRC msg', '', 'send', 'calcel', 1) end)

      s:hook("OnChat", function(user, channel, message)
	  if string.find(message, "ACTION") then
	  msgStr = Utf8ToAnsi(("{FFFF00}[IRC: %s] {800080} * %s %s"):format(channel, user.nick, message))
	  else
      msgStr = Utf8ToAnsi(("{FFFF00}[IRC: %s] {FF6600}<%s>{FFFFFF}: %s"):format(channel, user.nick, message))
	  end
    table.insert(chat,Utf8ToAnsi(("[%s] <%s> %s"):format(channel, user.nick, message)) )
	msgStr = string.gsub(msgStr, "00", "{FFFFFF}")
	msgStr = string.gsub(msgStr, "01", "{000000}")
	msgStr = string.gsub(msgStr, "02", "{000080}")
	msgStr = string.gsub(msgStr, "03", "{008000}")
	msgStr = string.gsub(msgStr, "04", "{FF0000}")
	msgStr = string.gsub(msgStr, "05", "{800000}")
	msgStr = string.gsub(msgStr, "06", "{800080}")
	msgStr = string.gsub(msgStr, "07", "{FF8000}")
	msgStr = string.gsub(msgStr, "08", "{FFFF00}")
	msgStr = string.gsub(msgStr, "09", "{00FF00}")
	msgStr = string.gsub(msgStr, "10", "{008080}")
	msgStr = string.gsub(msgStr, "11", "{00FFFF}")
	msgStr = string.gsub(msgStr, "12", "{0000FF}")
	msgStr = string.gsub(msgStr, "13", "{FF00FF}")
	msgStr = string.gsub(msgStr, "14", "{808080}")
	msgStr = string.gsub(msgStr, "15", "{AAAAAA}")
	msgStr = string.gsub(msgStr, "0", "{FFFFFF}")
	msgStr = string.gsub(msgStr, "1", "{000000}")
	msgStr = string.gsub(msgStr, "2", "{000080}")
	msgStr = string.gsub(msgStr, "3", "{008000}")
	msgStr = string.gsub(msgStr, "4", "{FF0000}")
	msgStr = string.gsub(msgStr, "5", "{800000}")
	msgStr = string.gsub(msgStr, "6", "{800080}")
	msgStr = string.gsub(msgStr, "7", "{FF8000}")
	msgStr = string.gsub(msgStr, "8", "{FFFF00}")
	msgStr = string.gsub(msgStr, "9", "{00FF00}")
	msgStr = string.gsub(msgStr, "ACTION", "{800080}")
	msgStr = string.gsub(msgStr, "", "{FFFFFF}")
	msgStr = string.gsub(msgStr, "", "{FFFFFF}")
      if irclogs then
        table.insert(IRCLogs, #IRCLogs + 1, "["..os.date("%H:%M").."] "..msgStr)
        fileLog = io.open("moonloader/IRCLOG.log", "w")
        for i = 1, #IRCLogs do
          fileLog:write(IRCLogs[i].."\n")
        end
        fileLog:close()
      end
	while string.len(msgStr) > 128 do 
		msgHalf = string.sub(msgStr, 1, 128)
		sampAddChatMessage(msgHalf, 0xffffff)
		msgStr = string.sub(msgStr, 129)
	end
		sampAddChatMessage(msgStr, 0xffffff)
      addOneOffSound(0.0, 0.0, 0.0, MessageSound)
      end)
      s:hook("OnRaw", function(line)
	  
	  
	  if string.find(line, "QUIT") ~= nil or string.find(line, "-b") ~= nil or string.find(line, "+b") ~= nil or string.find(line, "PART") ~= nil or string.find(line, "ChanServ@services.libera.chat NOTICE") ~= nil or string.find(line, "KICK #") ~= nil or string.find(line, "NICK :") ~= nil or string.find(line, "cobalt.libera.chat 353") ~= nil or string.find(line, "JOIN") ~= nil then
		StatusMsg = Utf8ToAnsi("{FFFF00}[IRC] {008000}"..line)
		StatusMsg = string.gsub(StatusMsg, "!", " (", 1)
		StatusMsg = string.gsub(StatusMsg, " PART", ") {ff0000}покинул{C37BF2}")
		StatusMsg = string.gsub(StatusMsg, " JOIN", ") {00ff00}зашел на{C37BF2}")
		StatusMsg = string.gsub(StatusMsg, " NICK :", ") {ffffff}Сменил ник на: {ff6600}")
		StatusMsg = string.gsub(StatusMsg, "ChanServ@services.libera.chat NOTICE", " {F19310}")
		StatusMsg = string.gsub(StatusMsg, ":cobalt.libera.chat 353", "{ffffff}Онлайн канала: {ff6600}")
		StatusMsg = string.gsub(StatusMsg, "=", "")
		
		StatusMsg = string.gsub(StatusMsg, " QUIT", ") {ff0000}покинул IRC-сервер.")
		-- продолжение/причина выхода:
		StatusMsg = string.gsub(StatusMsg, ":Ping timeout:", " {F19310}AFK ")
		StatusMsg = string.gsub(StatusMsg, "onds", ". <Alt+P> - вернутся в чат.")
		StatusMsg = string.gsub(StatusMsg, ":Remote host closed the connection", " {F19310}Вышел. | /q")
		StatusMsg = string.gsub(StatusMsg, ":Client Quit", " {F19310}Вышел. | /q")
		StatusMsg = string.gsub(StatusMsg, ":Read error: Connection reset by peer", " {F19310}Потеря связи/краш.")
		-- баны/разбаны/кики
		StatusMsg = string.gsub(StatusMsg, " KICK #", ") {ff0000}Кикнут с #")
		StatusMsg = string.gsub(StatusMsg, "MODE", "")
		StatusMsg = string.gsub(StatusMsg, "+b", " {ff0000}Забанен ")
		StatusMsg = string.gsub(StatusMsg, "-b", " {00ff00}Разбанен ")
		StatusMsg = string.gsub(StatusMsg, "Cannot join channel", " {ff0000}Вы на этом канале.")
		StatusMsg = string.gsub(StatusMsg, "- you are banned", " ")
		
		
		while string.len(StatusMsg) > 128 do 
		msgHalfs = string.sub(StatusMsg, 1, 128)
		sampAddChatMessage(msgHalfs, 0x008000)
		StatusMsg = string.sub(StatusMsg, 129)
		end
		sampAddChatMessage(StatusMsg, 0x008000)
      end
	  
	  
        if string.find(line, "353 "..Nick.." = "..Channel.." ") then
		
--[[    if string.find(line, "353 "..Nick.." = "..Channel.." ") then
		userlist = Utf8ToAnsi(line)
		userlist = string.gsub(userlist, " 353 ", " ", 1)
		userlist = string.gsub(userlist, Nick, "{ff6600}", 1)
		userlist = string.gsub(userlist, "=", "", 1)
		userlist = string.gsub(userlist, " ", "\n")
		userlist = string.gsub(userlist, "\n:", "{ffffff}\n\n")
		userlist = string.gsub(userlist, "%%", "{FF8000}%%{FFFFFF}")
		userlist = string.gsub(userlist, "@", "{FF0000}@{FFFFFF}")
		userlist = string.gsub(userlist, "+", "{00FF00}+{FFFFFF}")
		userlist = string.gsub(userlist, "~", "{FFFF00}~{FFFFFF}")
		userlist = string.gsub(userlist, "&", "{FF00FF}&{FFFFFF}")
		sampShowDialog(8048, "Онлайн канала "..Channel, userlist, "OK", "", 0)   --]]


		
	  end
      if DebugMode then
        msgStrs = Utf8ToAnsi("[IRC] RAW: "..line)
	msgStrs = string.gsub(msgStrs, "00", "{FFFFFF}")
	msgStrs = string.gsub(msgStrs, "01", "{000000}")
	msgStrs = string.gsub(msgStrs, "02", "{000080}")
	msgStrs = string.gsub(msgStrs, "03", "{008000}")
	msgStrs = string.gsub(msgStrs, "04", "{FF0000}")
	msgStrs = string.gsub(msgStrs, "05", "{800000}")
	msgStrs = string.gsub(msgStrs, "06", "{800080}")
	msgStrs = string.gsub(msgStrs, "07", "{FF8000}")
	msgStrs = string.gsub(msgStrs, "08", "{FFFF00}")
	msgStrs = string.gsub(msgStrs, "09", "{00FF00}")
	msgStrs = string.gsub(msgStrs, "10", "{008080}")
	msgStrs = string.gsub(msgStrs, "11", "{00FFFF}")
	msgStrs = string.gsub(msgStrs, "12", "{0000FF}")
	msgStrs = string.gsub(msgStrs, "13", "{FF00FF}")
	msgStrs = string.gsub(msgStrs, "14", "{808080}")
	msgStrs = string.gsub(msgStrs, "15", "{AAAAAA}")
	msgStrs = string.gsub(msgStrs, "0", "{FFFFFF}")
	msgStrs = string.gsub(msgStrs, "1", "{000000}")
	msgStrs = string.gsub(msgStrs, "2", "{000080}")
	msgStrs = string.gsub(msgStrs, "3", "{008000}")
	msgStrs = string.gsub(msgStrs, "4", "{FF0000}")
	msgStrs = string.gsub(msgStrs, "5", "{800000}")
	msgStrs = string.gsub(msgStrs, "6", "{800080}")
	msgStrs = string.gsub(msgStrs, "7", "{FF8000}")
	msgStrs = string.gsub(msgStrs, "8", "{FFFF00}")
	msgStrs = string.gsub(msgStrs, "9", "{00FF00}")
	while string.len(msgStrs) > 64 do 
		msgHalfs = string.sub(msgStrs, 1, 64)
		sampAddChatMessage(msgHalfs, 0xffff00)
		msgStrs = string.sub(msgStrs, 65)
	end
		sampAddChatMessage(msgStrs, 0xffff00)
      end
      end)
	 	
      s:connect(Server, Port)
      s:send("Nick %s", Nick)
      wait(200)
      s:join(Channel)
	  wait(25)
	  sampAddChatMessage("[IRC] {FFFFFF}Команды скрипта: {EE7878}/crr /cr /cme /crd /cri /cpm /crl", 0xFFFF00)
	  sampAddChatMessage("[IRC] {EE7878}<Alt+P> - {FFFFFF}Перезапускает скрипт.", 0xFFFF00)
	  sampAddChatMessage("[IRC] {FFFFFF}Подключение к IRC-серверу: {C37BF2}"..Server , 0xFFFF00)
	  sampAddChatMessage("[IRC] {FFFFFF}Подключение к каналу: {C37BF2}"..Channel , 0xFFFF00)
	  
	  

              

      while true do
        wait(IRCLatency)
        s:think()
end
end -- конец



    function ircsend(param)
      if #param > 0 then
        sampAddChatMessage("[IRC: "..Channel.."] {FF6600}<"..Nick..">{ffffff}: "..param, 0xFFFF00)
        table.insert(chat,'>'..string.gsub(param,'%{......%}', ''))
        sendstr = AnsiToUtf8(param)
        s:sendChat(Channel, sendstr)
      end
    end

    function ircquery(param)
      nick_send, msg = string.match(param, "^(%S*)%s(.*)$")
      sampAddChatMessage("[IRC PM Send]: {FF6600}"..tostring(nick_send).." {ffffff}"..tostring(msg), 0xFFFF00)
      sendstr = AnsiToUtf8(string.format("PRIVMSG %s :%s", nick_send, msg))
      s:send(sendstr)
    end
	
	
    function ircraw(param)
      sampAddChatMessage("[IRC] [RAW SEND]: "..param, 0xFFFF00)
      sendstr = AnsiToUtf8(param)
      s:send("%s", sendstr)
    end
	
	
	    function ircme(param)
      sampAddChatMessage("{FFFF00}[IRC: "..Channel.."]{800080} * "..Nick.." "..param, 0x800080)    -- cme
      sendstr = AnsiToUtf8(param)
      s:send("PRIVMSG %s ACTION %s", Channel, sendstr)
    end
	    function irclist()          -- онлайн канала
      s:send("NAMES %s", Channel)
    end
	
	
    function ircmenu()
      sampShowDialog(154, "Главное меню | Состояние: {0000FF}"..GetState(connected), string.format("{ffff00}Ник: {ffffff}%s \n{ffff00}IRC-сервер: {ffffff}%s \n{ffff00}Канал: {ffffff}%s\n{00ff00}Подключится\n{ff0000}Перезагрузить скрипт\nЧат-лог: {FF0000}%s\nАвто-подключение: {FF0000}%s\n{ffff00}Сохранить изменения\nЗвук сообщения: {FF0000}%d\nЛокальный пинг: {FF0000}%d\n{ff0000}Debug{ffffff}(для опытных): {FF0000}%s", Nick, Server, Channel, GetState(irclogs), GetState(AutoConnect), MessageSound, IRCLatency, GetState(DebugMode)), "Select", "Exit", 2)
end

------------------------------------------------------------------------------------------

function imgui.OnDrawFrame()

  if window.v then

    if isKeyDown(VK_RBUTTON) then
      imgui.ShowCursor = false
    else
      imgui.ShowCursor = true
    end

    imgui.SetNextWindowPos(imgui.ImVec2(select(1,getScreenResolution()) / 2, select(2,getScreenResolution()) / 2.3), imgui.Cond.FirstUseEver)
    -- imgui.SetNextWindowSize(imgui.ImVec2(200, 300), imgui.Cond.FirstUseEver)

    imgui.Begin('1', window, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoResize)

    if imgui.Button('CLEAR', imgui.ImVec2(-1,20)) then chat = {} end

    imgui.BeginChild('#a', imgui.ImVec2(450, 280), true)

    imgui.Text(u8(table.concat(chat,'\n')))

    imgui.EndChild()

    imgui.PushItemWidth(-1)
    if imgui.InputText('##buffer', buffer, imgui.InputTextFlags.EnterReturnsTrue) then
      if #buffer.v > 0 then
        ircsend(u8:decode(buffer.v))
        buffer.v = ''
      end 
    end

    imgui.End()

  end
end

---------------------------------------------------------------------------UPDATE-----------------------------------------------------

 --json_url https://www.dropbox.com/home/moonloader_update?preview=update.json
 --url https://www.blast.hk/threads/133136/
 
 -- json_url2

--
--     _   _   _ _____ ___  _   _ ____  ____    _  _____ _____   ______   __   ___  ____  _     _  __
--    / \ | | | |_   _/ _ \| | | |  _ \|  _ \  / \|_   _| ____| | __ ) \ / /  / _ \|  _ \| |   | |/ /
--   / _ \| | | | | || | | | | | | |_) | | | |/ _ \ | | |  _|   |  _ \\ V /  | | | | |_) | |   | ' /
--  / ___ \ |_| | | || |_| | |_| |  __/| |_| / ___ \| | | |___  | |_) || |   | |_| |  _ <| |___| . \
-- /_/   \_\___/  |_| \___/ \___/|_|   |____/_/   \_\_| |_____| |____/ |_|    \__\_\_| \_\_____|_|\_\                                                                                                                                                                                                                  
--
-- Author: http://qrlk.me/samp
--
function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      sampAddChatMessage((prefix..'Обновление завершено!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': Обновление не требуется.')
            end
          end
        else
          print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end











  ----------------------------------------------------------  МУСОР ЕБАНЫЙ ------------------------------------------------------
--[[
function main()
if not isSampLoaded() or not isSampfuncsLoaded() then return end
while not isSampAvailable() do wait(100) end


_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
nick = sampGetPlayerNickname(id)

downloadUrlToFile(update_url, update_path, function(id, status)
if status == dlstatus.STATUS_ENDDOWNLOADDATA then
    updateIni = inicfg.load(nil, update_path)
    if tonumber(updateIni.info.vers) > script_vers then
      sampAddChatMessage("[КАЗАХСТАН228]: Доступно новое обновление! Версия: " .. updateIni.info.vers_text, -1)
      update_state = true
      end
    os.remove(update_path)
  end
end)

      while true do
      wait(0)

      if update_state then
        downloadUrlToFile(script_url, script_path, function(id, status)
          if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            sampAddChatMessage("Скрипт обновлен!", -1)
            thisScript():reload()


            end
          end)
          break
              



  end
end  

 --]]
--------------------------------------------------------------------  
	
--[[ _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick44 = sampGetPlayerNickname(id)
	local Nick2 = ("" .. nick44)  --]]