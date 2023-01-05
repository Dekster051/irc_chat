script_name("[IRC]-Samp")
script_author("Deks51")
script_version('1.3.10')

require "luairc"
local irc_vers = "{00ff00}1.3.10" 
local tag = "{00ffff}| {ffb700}IRC {00ffff}| "
local clr1 = "{ffb700}"
local clr2 = "{AAAAAA}"


local inicfg = require 'inicfg'
local iniIrcFile = 'irc samp.ini'  -- iniIrc.config.
local iniIrc = inicfg.load({
	config = { 
		Pass0 = "-",
		Poziv = "-",
		Channel1 = "#samp",
		Channel2 = "-",
		Key1 = "-",
		Key2 = "-",
		AutoConnect = true,
		MessageSound = 1058,
	},
	cmd = {                    -- iniIrc.cmd.
		menu0 = "irc", 
		pmsend0 = "cpm", 
		user0 = "crl",
		kick0 = "ckick", --
		ban0 = "cban",   --
		uban0 = "cuban", --
		blist0 = "cbl",  --
		send1 = "cr", 
		send2 = "k",
		pos1 = "crd", 
		pos2 = "krd",
	}	
}, iniIrcFile)
inicfg.save(iniIrc, iniIrcFile)

DebugMode = false
local s = irc.new{nick = "nil"}
connected = false
Uvedom = true
pos1 = false
pos2 = false
Channel11 = string.format('%spos',iniIrc.config.Channel1)
Channel22 = string.format('%spos',iniIrc.config.Channel2)


pool = {}

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
function GetState(var)
  if var then
  return "{00FF00}On"
  else
  return "{FF0000}Off"
  end
end

function main()
  while not isSampAvailable() do wait(100) end
    wait(1000)
    local thread1 = lua_thread.create(secondThread, false)
    while not isSampAvailable() or not connected do wait(100) end
autoupdate("https://raw.githubusercontent.com/Dekster051/irc_chat/main/-version.json", '['..string.upper(thisScript().name)..']: ', "https://raw.githubusercontent.com/Dekster051/irc_chat/main/-version.json")
    lua_thread.create(removeBlipf)

      local sleep = require "socket".sleep
	  	  
	  sampRegisterChatCommand("dcrr", dcrr)
      sampRegisterChatCommand("crr", ircraw)
	  sampRegisterChatCommand(iniIrc.cmd.pmsend0, PrivateSend)
      sampRegisterChatCommand(iniIrc.cmd.send1, send1)
	  sampRegisterChatCommand(iniIrc.cmd.send2, send2)
	  sampRegisterChatCommand(iniIrc.cmd.user0, user0)
	  sampRegisterChatCommand(iniIrc.cmd.pos1, pos11f)
	  sampRegisterChatCommand(iniIrc.cmd.pos2, pos22f)
	  sampRegisterChatCommand(iniIrc.cmd.kick0, kick0)
	  sampRegisterChatCommand(iniIrc.cmd.ban0, ban0)
	  sampRegisterChatCommand(iniIrc.cmd.uban0, uban0)
	  sampRegisterChatCommand(iniIrc.cmd.blist0, blist0)
	--=============================================ХУКИ=========================================--
s:hook("OnKick", function(channel, nick, kicker, reason)
if channel == Channel11 or channel == Channel22 then else
reason = Utf8ToAnsi(reason)
	sampAddChatMessage(string.format(""..tag..clr1.."%s "..clr2.."кикнул(а) с "..clr1.."%s %s "..clr2.."причина: "..clr1.."%s", kicker.nick, channel, nick, reason), -1)
end
end)
	
s:hook("OnJoin", function(user, channel)
if Uvedom then
	if channel == Channel11 or channel == Channel22 then else
    sampAddChatMessage(string.format(""..tag..clr1.."%s "..clr2.."зашел(а) в "..clr1.."%s", user.nick, channel), -1) 
	end
end	
end)

s:hook("OnPart", function(user, channel)
if channel == Channel11 or channel == Channel22 then else
    sampAddChatMessage(string.format(""..tag..clr1.."%s "..clr2.."покинул(а) "..clr1.."%s", user.nick, channel), -1)  
	end
end)

s:hook("OnQuit", function(user, channel)
sampAddChatMessage(string.format(""..tag..clr1.."%s "..clr2.."отключился(лась) от "..clr1.."IRC{ffffff} | "..clr1.."%s", user.nick, channel), -1)
end)

--[[s:hook("NickChange", function(user, newnick, channel)	
if Uvedom then
if channel == iniIrc.config.Channel1 or channel == iniIrc.config.Channel2 then
    sampAddChatMessage(string.format(""..tag..clr1.."%s "..clr2.."Сменил ник на "..clr1.."%s", user.nick, newnick), -1)
	end
	end
end) --]]

s:hook("OnModeChange", function(user, target, modes, ...)
if channel == Channel11 or channel == Channel22 then else
	if modes:find("b") then
        local banNick = string.match(..., "(%S+)")
        if modes == "-b" then
    sampAddChatMessage(string.format(""..tag..clr1.."%s {00ff00}разбанил(а) "..clr1.."%s", user.nick, banNick), -1)
	else
	sampAddChatMessage(string.format(""..tag..clr1.."%s {F92222}забанил(а) "..clr1.."%s", user.nick, banNick), -1)
	end
	end

if Uvedom then
	if modes:find("k") then
        if modes == "-k" then
    sampAddChatMessage(string.format(""..tag..clr1.."%s "..clr2.."удалил(а) пароль на канале.", user.nick), -1)
	else
	sampAddChatMessage(string.format(""..tag..clr1.."%s "..clr2.."установил(а) пароль на канале: "..clr1.."%s", user.nick, ...), -1)
	end
	end
	
	if modes:find("l") then
        if modes == "-l" then
    sampAddChatMessage(string.format(""..tag..clr1.."%s "..clr2.."удалил(а) лимит учасников на канале", user.nick), -1)
	else
	sampAddChatMessage(string.format(""..tag..clr1.."%s "..clr2.."установил(а) лимит учасников на канале: "..clr1.."%s", user.nick, ...), -1)
	end
	end

	end
  end
end)
	
s:hook("OnChat", function(user, channel, message)  

if channel == iniIrc.config.Channel1 or channel == Channel11 then
if string.find(message, Utf8ToAnsi("15Coordination 09On")) then
	  if pos1 == true then
		pos11fp()
	  end
end --]]
if string.find(message, Utf8ToAnsi(id1..' crd')) or string.find(message, Utf8ToAnsi(Nick22..' crd')) then
	  pos11fp()
	  end
if string.find(message, Utf8ToAnsi(id1..' server')) or string.find(message, Utf8ToAnsi(Nick22..' server')) then
	  send1('15( '..sampGetCurrentServerName()..' )')
	  end
if string.find(message, Utf8ToAnsi(id1..' vers')) or string.find(message, Utf8ToAnsi(Nick22..' vers')) then
		 send1('15My vers: 09'..irc_vers)
	  end
if string.find(message, Utf8ToAnsi('ids')) or string.find(message, Utf8ToAnsi('ids')) then
		 send1("id")
	  end
if string.find(message, Utf8ToAnsi('%[!%]my coord%: ')) then
          a,b,c = message:match('x%:(.+),y%:(.+),z%:(.+)')

          removeBlip(pool[1])
          pool[1] = addBlipForCoord((a),(b),(c))
          changeBlipColour(pool[1], 0x00ff00FF)
        end
end

if channel == iniIrc.config.Channel2 or channel == Channel22 then
if string.find(message, Utf8ToAnsi("15Coordination 09On")) then
	  if pos2 == true then
		pos22fp()
	  end
end
if string.find(message, Utf8ToAnsi(id1..' crd')) or string.find(message, Utf8ToAnsi(Nick22..' crd')) then
	  pos22fp()
	  end
if string.find(message, Utf8ToAnsi(id1..' server')) or string.find(message, Utf8ToAnsi(Nick22..' server')) then
	  send2('15( '..sampGetCurrentServerName()..' )')
	  end
if string.find(message, Utf8ToAnsi(id1..' vers')) or string.find(message, Utf8ToAnsi(Nick22..' vers')) then
		 send2('15My vers: 09'..irc_vers)
	  end
if string.find(message, Utf8ToAnsi('ids')) or string.find(message, Utf8ToAnsi('ids')) then
		 send2("id")
	  end
if string.find(message, Utf8ToAnsi('%[!%]my coord%: ')) then
          a,b,c = message:match('x%:(.+),y%:(.+),z%:(.+)')

          removeBlip(pool[2])
          pool[2] = addBlipForCoord((a),(b),(c))
          changeBlipColour(pool[2], 0x00ffffFF)
        end
end

if channel == iniIrc.config.Nick1 then
	msgStr = Utf8ToAnsi((""..tag..clr1.."PM"..clr2.." < "..clr1.."%s{ffffff} %s"):format(user.nick, message))	
	msgStr = string.gsub(msgStr, "VERSION", "{00FF00}Подключено!")
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
	msgStr = string.gsub(msgStr, "ACTION", "{008000}")
	msgStr = string.gsub(msgStr, "", "{FFFFFF}")
	msgStr = string.gsub(msgStr, "", "{FFFFFF}") 
while string.len(msgStr) > 128 do 
		msgHalf = string.sub(msgStr, 1, 128)
		sampAddChatMessage(msgHalf, 0xffffff)
		msgStr = string.sub(msgStr, 129)
	end
	  addOneOffSound(0.0, 0.0, 0.0, iniIrc.config.MessageSound)
	  sampAddChatMessage(msgStr, 0xffffff)	
elseif channel == iniIrc.config.Channel1 then
      msgStr = Utf8ToAnsi(("{00ffff}| {3AD359}%s {00ffff}| "..clr1.."%s{ffffff} %s"):format(channel, user.nick, message))
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
	msgStr = string.gsub(msgStr, "ACTION", "{008000}")
	msgStr = string.gsub(msgStr, "", "{FFFFFF}")
	msgStr = string.gsub(msgStr, "", "{FFFFFF}")   
	  while string.len(msgStr) > 128 do 
		msgHalf = string.sub(msgStr, 1, 128)
		sampAddChatMessage(msgHalf, 0xffffff)
		msgStr = string.sub(msgStr, 129)
	end
	  addOneOffSound(0.0, 0.0, 0.0, iniIrc.config.MessageSound)
	  sampAddChatMessage(msgStr, 0xffffff)
elseif channel == iniIrc.config.Channel2  then
	  msgStr = Utf8ToAnsi(("{00ffff}| {25BFC6}%s {00ffff}| "..clr1.."%s{ffffff} %s"):format(channel, user.nick, message))
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
	msgStr = string.gsub(msgStr, "ACTION", "{008000}")
	msgStr = string.gsub(msgStr, "", "{FFFFFF}")
	msgStr = string.gsub(msgStr, "", "{FFFFFF}") 
while string.len(msgStr) > 128 do 
	    msgHalf = string.sub(msgStr, 1, 128)
		sampAddChatMessage(msgHalf, 0xffffff)
		msgStr = string.sub(msgStr, 129)
	end
	  addOneOffSound(0.0, 0.0, 0.0, iniIrc.config.MessageSound)
	  sampAddChatMessage(msgStr, 0xffffff)
  end 
end)
	  
s:hook("OnRaw", function(line)	  
----------------------------------------------------------------RIZON ----------------------------------------------------------------	
if string.find(line, ":.+ 431 "..iniIrc.config.Nick1) ~= nil or string.find(line, ":.+ 412 "..iniIrc.config.Nick1) ~= nil or string.find(line, ":.+ 499 "..iniIrc.config.Nick1) ~= nil or string.find(line, ":.+ 401 "..iniIrc.config.Nick1) ~= nil or string.find(line, ":.+ 475 "..iniIrc.config.Nick1) ~= nil or string.find(line, ":.+ 473 "..iniIrc.config.Nick1) ~= nil or string.find(line, ":.+ 461 "..iniIrc.config.Nick1) ~= nil or string.find(line, ":.+ 482 "..iniIrc.config.Nick1) ~= nil or string.find(line, ":.+ 352 "..iniIrc.config.Nick1) ~= nil or string.find(line, ":.+ 404 "..iniIrc.config.Nick1) ~= nil or string.find(line, ":.+ 474 "..iniIrc.config.Nick1) ~= nil or string.find(line, "ChanServ!service@rizon.net NOTICE "..iniIrc.config.Nick1) ~= nil then  
		StatusMsg = Utf8ToAnsi(""..tag.."{008000}"..line)						
		StatusMsg = string.gsub(StatusMsg, ":.+ #", clr2.."#")
		
		StatusMsg = string.gsub(StatusMsg, "You're not channel operator", " {FF4C4C}Вы не оператор канала.")
		StatusMsg = string.gsub(StatusMsg, "You're not a channel owner", " {FF4C4C}Вы не владелец канала.")
		StatusMsg = string.gsub(StatusMsg, "Cannot send to channel", " {FF4C4C}Невозможно отправить сообщение на канал.")
		StatusMsg = string.gsub(StatusMsg, "Cannot join channel", " {FF4C4C}Невозможно подключиться к каналу.")
		StatusMsg = string.gsub(StatusMsg, "No such nick/channel", " {FF4C4C}Нет такого ника / канала.")
		StatusMsg = string.gsub(StatusMsg, "Not enough parameters", "{FF4C4C}Недостаточное количество параметров.")
		StatusMsg = string.gsub(StatusMsg, "No text to send", " {FF4C4C}Нет текста для отправки.")
		StatusMsg = string.gsub(StatusMsg, "No nickname given", " {FF4C4C}Псевдоним не указан.")
		
		StatusMsg = string.gsub(StatusMsg, ":.+ :", "")
		
		while string.len(StatusMsg) > 128 do 
		msgHalfs = string.sub(StatusMsg, 1, 128)
		sampAddChatMessage(msgHalfs, 0x008000)
		StatusMsg = string.sub(StatusMsg, 129)
		end
		sampAddChatMessage(StatusMsg, 0x008000)
      end
--========================================================================================================
-- :Dekster_DeShon!~lua@F803883B.FB897707.A0F661A0.IP NICK :Pedro228
if string.find(line, "NICK :.+") ~= nil then
StatusMsg = Utf8ToAnsi(""..tag..clr1..line)
StatusMsg = string.gsub(StatusMsg, ":", "")
StatusMsg = string.gsub(StatusMsg, "!~.+ NICK", " "..clr2.."сменил(а) ник на: "..clr1)

while string.len(StatusMsg) > 128 do 
		msgHalfs = string.sub(StatusMsg, 1, 128)
		sampAddChatMessage(msgHalfs, 0x008000)
		StatusMsg = string.sub(StatusMsg, 129)
		end
		sampAddChatMessage(StatusMsg, 0x008000)
end
--===========================================CRLIST=============================================================  
if Uvedom then -- :irc.anonchan.com 353 Dekster_DeShon @ #okko :John_Felens Dekster_DeShon Damilola_Karpow ~@DeksterOP @Zakarym666
	if string.find(line, "353 "..iniIrc.config.Nick1) then
		userlist = Utf8ToAnsi(line)
		userlist = string.gsub(userlist, ":.+ 353 .+ :", "")
		userlist = string.gsub(userlist, " ", "\n")
		userlist = string.gsub(userlist, "\n:", "{ffffff}\n\n")
		userlist = string.gsub(userlist, "~@", "{FFFF00}[Owner] {FFFFFF}")
		userlist = string.gsub(userlist, "&@", "{FF00FF}[Admin] {FFFFFF}")
		userlist = string.gsub(userlist, "@", "{FF0000}[Oper] {FFFFFF}")
		userlist = string.gsub(userlist, "%%", "{FF8000}%[HalfOP] {FFFFFF}")
		userlist = string.gsub(userlist, "+", "{00FF00}[Voice] {FFFFFF}")
		
		userlist = string.gsub(userlist, "~", "{FFFF00}[Owner] {FFFFFF}")
		userlist = string.gsub(userlist, "&", "{FF00FF}[Admin] {FFFFFF}")
		sampShowDialog(8048, "Онлайн канала", "{ffffff}"..userlist, "ОК", "", 0)			
	end		
end
--=============================================BANLIST===========================================================
  -- :irc.anonchan.com 367 Dekster_DeShon #okko EbaloSnositel!*@* Dekster_DeShon!~lua@Rizon-E44C218B.pool.ukrtel.net 1662735380
if string.find(line, "367 "..iniIrc.config.Nick1) then
		StatusMsg = Utf8ToAnsi(""..tag.."{008000}"..line)
		StatusMsg = string.gsub(StatusMsg, ":.+ 367 .+ #", "{FF4C4C}#")
		StatusMsg = string.gsub(StatusMsg, "!~.+", "")
		
while string.len(StatusMsg) > 128 do 
		msgHalfs = string.sub(StatusMsg, 1, 128)
		sampAddChatMessage(msgHalfs, 0x008000)
		StatusMsg = string.sub(StatusMsg, 129)
		end
		sampAddChatMessage(StatusMsg, 0x008000)
      end
		
--========================================================================================================
if string.find(line, "001 "..iniIrc.config.Nick1.." :Welcome to the Rizon Internet Relay Chat Network") ~= nil then
		s:send("NickServ IDENTIFY %s", iniIrc.config.Pass0)
	wait(50)
		s:join(iniIrc.config.Channel1, iniIrc.config.Key1)
		s:join(iniIrc.config.Channel2, iniIrc.config.Key2)
	wait(2000)
     if Uvedom == false then
		 Uvedom = not Uvedom
     end
end
----------------------------------------------------------------------------------------------------------
if string.find(line, "NICK :"..iniIrc.config.Nick1) ~= nil then
s:send("NickServ IDENTIFY %s", iniIrc.config.Pass0)
	wait(50)
s:join(iniIrc.config.Channel1, iniIrc.config.Key1)
s:join(iniIrc.config.Channel2, iniIrc.config.Key2)
 if Uvedom == false then
	Uvedom = not Uvedom
  end
end
----------------------------------------------------------------------------------------------------------
--:Nickname is already in use.
if string.find(line, ":Nickname is already in use") ~= nil then
lua_thread.create(spnick)
end
----------------------------------------------------------------------------------------------------------
-- :Dekster_DeShon|770!~lua@80CF1790.25F024A2.7EFFA1DC.IP JOIN :#dfsf
if string.find(line, ":"..iniIrc.config.Nick1.."!.+ JOIN :"..iniIrc.config.Channel1) ~= nil then
s:join(Channel11, iniIrc.config.Key1)
end 

if string.find(line, ":"..iniIrc.config.Nick1.."!.+ JOIN :"..iniIrc.config.Channel2) ~= nil then
s:join(Channel22, iniIrc.config.Key2)
end --]]
----------------------------------------------------------------------------------------------------------
if string.find(line, "KICK "..iniIrc.config.Channel1.." "..iniIrc.config.Nick1) ~= nil then
s:part(Channel11)
end 

if string.find(line, "KICK "..iniIrc.config.Channel2.." "..iniIrc.config.Nick1) ~= nil then
s:part(Channel22)
end 
----------------------------------------------------------------------------------------------------------
if string.find(line, "ERROR :Closing Link:") ~= nil then
removeBlip(pool[1])	
removeBlip(pool[2])
sampAddChatMessage(""..tag.."{ffffff}Вы были отключены от "..clr1.."IRC{ffffff}, переподключаемся...", 0x00ff00)
thisScript():reload()
end
--========================================================================================================	  
if DebugMode then
        msgStrs = Utf8ToAnsi(""..tag.."{ffff00}RAW: "..line)
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
--=============================================================================================================================================
  Uvedom = not Uvedom
      s:connect("irc.losslessone.com", Port)  -- irc.rizon.net  irc.ea.libera.chat   irc.esper.net
	  sampAddChatMessage(""..tag..clr2.."Подключение...", -1)

      while true do
        wait(555)
        s:think() 
	end	  
end         -- конец
--========================================================================================================================================================
function user0(param)
	if param == nil or param == "" then  
      s:send("NAMES %s", iniIrc.config.Channel1)
	end
	if param == "2" then  
      s:send("NAMES %s", iniIrc.config.Channel2)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function send1(param)
	if #param == 0 then
		sampAddChatMessage(""..tag..clr2.."Введите "..clr1.."/"..iniIrc.cmd.send1.." [text]", -1)
    elseif iniIrc.config.Poziv == "-" then
      sampAddChatMessage("{00ffff}| {3AD359}"..iniIrc.config.Channel1.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {FF8000}|"..id1.."|{ffffff}: "..param, -1)
	  sendstr = AnsiToUtf8(string.format("07|%s|: %s", id1, param))
      s:sendChat(iniIrc.config.Channel1, sendstr)
	else
      sampAddChatMessage("{00ffff}| {3AD359}"..iniIrc.config.Channel1.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {FF8000}|"..iniIrc.config.Poziv.." "..id1.."|{ffffff}: "..param, -1)
	  sendstr = AnsiToUtf8(string.format("07|%s %s|: %s", iniIrc.config.Poziv, id1, param))
      s:sendChat(iniIrc.config.Channel1, sendstr)
    end	
end
function send11(param)   
	sendstr = AnsiToUtf8(param) 
      s:sendChat(Channel11, sendstr)
end	
---------------------------------------------------------------------------------------------------------------------------------------------
function send2(param) 
	if #param == 0 then
		sampAddChatMessage(""..tag..clr2.."Введите "..clr1.."/"..iniIrc.cmd.send2.." [text]", -1)
	elseif iniIrc.config.Poziv == "-" then
	  sampAddChatMessage("{00ffff}| {25BFC6}"..iniIrc.config.Channel2.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {FF8000}|"..id1.."|{ffffff}: "..param, -1)
	  sendstr = AnsiToUtf8(string.format("07|%s|: %s", iniIrc.config.Poziv, id1, param))
      s:sendChat(iniIrc.config.Channel2, sendstr)
	else
      sampAddChatMessage("{00ffff}| {25BFC6}"..iniIrc.config.Channel2.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {FF8000}|"..iniIrc.config.Poziv.." "..id1.."|{ffffff}: "..param, -1)
	  sendstr = AnsiToUtf8(string.format("07|%s %s|: %s", iniIrc.config.Poziv, id1, param))
      s:sendChat(iniIrc.config.Channel2, sendstr)
    end	
end
function send22(param)   
	sendstr = AnsiToUtf8(param) 
      s:sendChat(Channel22, sendstr)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function PrivateSend(param)
	if #param == 0 then
		sampAddChatMessage(""..tag..clr2.."Введите "..clr1.."/"..iniIrc.cmd.pmsend0.." [Nick] [text]", -1)
		else
      nick_send, msg = string.match(param, "^(%S*)%s(.*)$")
      sampAddChatMessage(""..tag..clr1.."PM"..clr2.." > "..clr1..tostring(nick_send).."{ffffff}: "..tostring(msg), -1)
      sendstr = AnsiToUtf8(string.format("PRIVMSG %s :07|%s|: %s", nick_send, id1, msg))
      s:send(sendstr)
    end
end --]]
--[[function PrivateSend(param)
param1, param2 = string.match(param, "(.+) (.+)")
	if param1 == nil or param1 == "" or param2 == nil or param2 == "" then  
	sampAddChatMessage(""..tag..clr2.."Введите "..clr1.."/"..iniIrc.cmd.pmsend0.." [Nick] [text]", -1)
	else
      sampAddChatMessage(""..tag..clr1.."PM"..clr2.." > "..clr1..param1.."{ffffff}: "..param2, -1)
      sendstr = AnsiToUtf8(string.format("PRIVMSG %s :07%s: %s", param1, id1, param2))
      s:send(sendstr)
    end
end --]]
---------------------------------------------------------------------------------------------------------------------------------------------		
function pos11f(param)
if #param == 0 then
		pos1 = not pos1
			if pos1 == true then
				sampAddChatMessage("{00ffff}| {3AD359}"..iniIrc.config.Channel1.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {AAAAAA}Coordination {00ff00}On", -1)
				sendstr = AnsiToUtf8("15Coordination 09On")
				s:sendChat(iniIrc.config.Channel1, sendstr)			
			end
			if pos1 == false then
				sampAddChatMessage("{00ffff}| {3AD359}"..iniIrc.config.Channel1.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {AAAAAA}Coordination {ff0000}Off", -1)
				sendstr = AnsiToUtf8("15Coordination 04Off")
				s:sendChat(iniIrc.config.Channel1, sendstr)
			end
		lua_thread.create(pos1f)
	else
		sendstr = (string.format("%s crd", param))
		send11(sendstr)
	end
end
function pos11fp()
		pos1 = not pos1
			if pos1 == true then
				sampAddChatMessage("{00ffff}| {3AD359}"..iniIrc.config.Channel1.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {AAAAAA}Coordination {00ff00}On", -1)
				sendstr = AnsiToUtf8("15Coordination 09On")
				s:sendChat(iniIrc.config.Channel1, sendstr)			
			end
			if pos1 == false then
				sampAddChatMessage("{00ffff}| {3AD359}"..iniIrc.config.Channel1.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {AAAAAA}Coordination {ff0000}Off", -1)
				sendstr = AnsiToUtf8("15Coordination 04Off")
				s:sendChat(iniIrc.config.Channel1, sendstr)
			end
		lua_thread.create(pos1f)
end
function pos1f()
while pos1 do 
		wait(1000)
if getCharActiveInterior(PLAYER_PED) == 0 then
        x,y,z = getCharCoordinates(PLAYER_PED)
        send11(''..clr2..'[!]my coord: {00ff00}x:'.. math.floor(x) .. ',y:'..math.floor(y).. ',z:'..math.floor(z)..'')
      else
		pos1 = not pos1
		if pos1 == false then
				sampAddChatMessage("{00ffff}| {3AD359}"..iniIrc.config.Channel1.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {AAAAAA}You in interior! | {ff0000}Off", -1)
				sendstr = AnsiToUtf8("15You in interior! | 04Off")
				s:sendChat(iniIrc.config.Channel1, sendstr)
		end	
	  end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function pos22f(param)
if #param == 0 then
		pos2 = not pos2
			if pos2 == true then
				sampAddChatMessage("{00ffff}| {25BFC6}"..iniIrc.config.Channel2.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {AAAAAA}Coordination {00ff00}On", -1)
				sendstr = AnsiToUtf8("15Coordination 09On")
				s:sendChat(iniIrc.config.Channel2, sendstr)			
			end
			if pos2 == false then
				sampAddChatMessage("{00ffff}| {25BFC6}"..iniIrc.config.Channel2.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {AAAAAA}Coordination {ff0000}Off", -1)
				sendstr = AnsiToUtf8("15Coordination 04Off")
				s:sendChat(iniIrc.config.Channel2, sendstr)
			end
		lua_thread.create(pos2f)
	else
		sendstr = (string.format("%s crd", param))
		send22(sendstr)
	end
end
function pos22fp()
		pos2 = not pos2
			if pos2 == true then
				sampAddChatMessage("{00ffff}| {25BFC6}"..iniIrc.config.Channel2.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {AAAAAA}Coordination {00ff00}On", -1)
				sendstr = AnsiToUtf8("15Coordination 09On")
				s:sendChat(iniIrc.config.Channel2, sendstr)			
			end
			if pos2 == false then
				sampAddChatMessage("{00ffff}| {25BFC6}"..iniIrc.config.Channel2.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {AAAAAA}Coordination {ff0000}Off", -1)
				sendstr = AnsiToUtf8("15Coordination 04Off")
				s:sendChat(iniIrc.config.Channel2, sendstr)
			end
		lua_thread.create(pos2f)
end
function pos2f()
while pos2 do 
		wait(1000)
if getCharActiveInterior(PLAYER_PED) == 0 then
        x,y,z = getCharCoordinates(PLAYER_PED)
        send22(''..clr2..'[!]my coord: {00ff00}x:'.. math.floor(x) .. ',y:'..math.floor(y).. ',z:'..math.floor(z)..'')
      else
		pos2 = not pos2
		if pos2 == false then
				sampAddChatMessage("{00ffff}| {25BFC6}"..iniIrc.config.Channel2.." {00ffff}| "..clr1..iniIrc.config.Nick1.." {AAAAAA}You in interior! | {ff0000}Off", -1)
				sendstr = AnsiToUtf8("15You in interior! | 04Off")
				s:sendChat(iniIrc.config.Channel2, sendstr)
		end	
	  end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function kick0(param)
param1, param2, param3 = string.match(param, "(.+) (.+) (.+)")
	if param2 == nil or param3 == nil then  
	sampAddChatMessage(""..tag..clr2.."Введите "..clr1.."/"..iniIrc.cmd.kick0.." [ {3AD359}1 {ffffff}или {25BFC6}2"..clr1.." ] [Nick] [причина]", -1)
	end
	 if param1 == "1" then
	 param33 = AnsiToUtf8(param3)
      s:send("kick %s %s %s", iniIrc.config.Channel1, param2, param33)
    end
	if param1 == "2" then
	 param33 = AnsiToUtf8(param3)
      s:send("kick %s %s %s", iniIrc.config.Channel2, param2, param33)
    end
end
function ban0(param)
param1, param2 = string.match(param, "(.+) (.+)")
	if param2 == nil then  
	sampAddChatMessage(""..tag..clr2.."Введите "..clr1.."/"..iniIrc.cmd.ban0.." [ {3AD359}1 {ffffff}или {25BFC6}2"..clr1.." ] [Nick]", -1)
	end
	 if param1 == "1" then
      s:send("mode %s +b %s", iniIrc.config.Channel1, param2)
    end
	if param1 == "2" then
      s:send("mode %s +b %s", iniIrc.config.Channel2, param2)
    end
end
function uban0(param)
param1, param2 = string.match(param, "(.+) (.+)")
	if param2 == nil then  
	sampAddChatMessage(""..tag..clr2.."Введите "..clr1.."/"..iniIrc.cmd.uban0.." [ {3AD359}1 {ffffff}или {25BFC6}2"..clr1.." ] [Nick]", -1)
	end
	 if param1 == "1" then
      s:send("mode %s -b %s!*@*", iniIrc.config.Channel1, param2)
    end
	if param1 == "2" then
      s:send("mode %s -b %s!*@*", iniIrc.config.Channel2, param2)
    end
end
function blist0(param)
	if param == "" then  
	sampAddChatMessage(""..tag..clr2.."Введите "..clr1.."/"..iniIrc.cmd.blist0.." [ {3AD359}1 {ffffff}или {25BFC6}2"..clr1.." ]", -1)
	end
	 if param == "1" then
      s:send("mode %s +b", iniIrc.config.Channel1)
    end
	if param == "2" then
      s:send("mode %s +b", iniIrc.config.Channel2)
    end
end
--========================================================================================================================================================
--==================================================MENU==============================================--

function secondThread()
  while not isSampfuncsLoaded() do
    wait(1000)
  end

  while not sampIsLocalPlayerSpawned() do wait(1) end
  
  local id = select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))
	local Nick2 = sampGetPlayerNickname(id)
	s.nick = string.format('|%s|', Nick2)
	iniIrc.config.Nick1 = s.nick
		inicfg.save(iniIrc, iniIrcFile)
		id1 = id
		Nick22 = Nick2
		
	
  if iniIrc.config.AutoConnect then
	print("IRC_Samp "..irc_vers.." "..clr2.."| by "..clr1.."Deks51 "..clr2.."Загружен. "..clr1.."/"..iniIrc.cmd.menu0.." - "..clr2.."Главное меню.")
    connected = true
	else
	sampAddChatMessage(""..clr1.."IRC_Samp "..irc_vers.." "..clr2.."| by "..clr1.."Deks51 "..clr2.."Загружен. "..clr1.."/"..iniIrc.cmd.menu0.." - "..clr2.."Главное меню.", -1)
  end
  
  sampRegisterChatCommand(iniIrc.cmd.menu0, function()
  sampShowDialog(154, ""..clr2.."Меню "..clr1.."IRC Samp "..irc_vers.." "..clr2.."| Состояние: {0000FF}"..GetState(connected), string.format(""..clr2.."Пароль от ника в {00ff00}IRC{ffffff}: "..clr1.."%s\n"..clr2.."Позывное: "..clr1.."%s\n"..clr2.."Канал1: {3AD359}%s\n"..clr2.."Канал2: {25BFC6}%s\n"..clr2.."Параметры команд\n{00ff00}Подключится\n{ffff00}Переподключится\n{ff0000}Отключится\n"..clr2.."Авто-подключение: "..clr1.."%s\n"..clr2.."Звук сообщения: "..clr1.."%d", iniIrc.config.Pass0, iniIrc.config.Poziv, iniIrc.config.Channel1, iniIrc.config.Channel2, GetState(iniIrc.config.AutoConnect), iniIrc.config.MessageSound), "Выбрать", "Выйти", 2)
  end)
 
  while true do
    wait(0)
			
	local resultMain, buttonMain, listMain = sampHasDialogRespond(154)
    if resultMain == true then
      if buttonMain == 1 then
	  
        if listMain == 0 then   	
		sampShowDialog(1991, ""..clr1.."Пароль", ""..clr2.."Введите пароль от "..clr1..iniIrc.config.Nick1..clr2.." если он зарегистрирован на сервере {00ff00}IRC", "Ok", "Отмена", 1) 
        end
		
		if listMain == 1 then   	
		sampShowDialog(1845, ""..clr1.."Позывное", ""..clr2.."Введите свое позывное", "Ok", "Отмена", 1) 
        end
		
		if listMain == 2 then   
		s:part(iniIrc.config.Channel1)	
        s:part(Channel11)		
		sampShowDialog(1291, ""..clr1.."Канал1", ""..clr2.."Введите имя Канала. Начиная с "..clr1.."#", "Ok", "Отмена", 1) 
        end
		
		if listMain == 3 then
		s:part(iniIrc.config.Channel2)	
        s:part(Channel22)		
		sampShowDialog(1290, ""..clr1.."Канал2", ""..clr2.."Введите имя Канала. Начиная с "..clr1.."#", "Ok", "Отмена", 1) 
        end
		
		if listMain == 4 then                                                                               
          sampShowDialog(1541, "Параметры команд", string.format(""..clr2.."Главное меню: "..clr1.."/%s\n"..clr2.."Личное сообщение: "..clr1.."/%s Nick\n"..clr2.."Онлайн каналов 1 и 2: {3AD359}/%s {ffffff}| {25BFC6}/%s 2\n"..clr2.."Кик с каналов 1 и 2: {3AD359}/%s 1 {ffffff}| {25BFC6}/%s 2\n"..clr2.."Бан с каналов 1 и 2: {3AD359}/%s 1 {ffffff}| {25BFC6}/%s 2\n"..clr2.."РазБан на каналах 1 и 2: {3AD359}/%s 1 {ffffff}| {25BFC6}/%s 2\n"..clr2.."БанЛист каналов 1 и 2: {3AD359}/%s 1 {ffffff}| {25BFC6}/%s 2\n                              <<<{3AD359}Канал1{ffffff}>>>\n"..clr2.."Сообщение каналу: {3AD359}/%s\n"..clr2.."Отправить корды: {3AD359}/%s {ffffff}| "..clr2.."Запросить корды: {3AD359}/%s id\n                              <<<{25BFC6}Канал2{ffffff}>>>\n"..clr2.."Сообщение каналу: {25BFC6}/%s\n"..clr2.."Отправить корды: {25BFC6}/%s {ffffff}| "..clr2.."Запросить корды: {25BFC6}/%s id", iniIrc.cmd.menu0, iniIrc.cmd.pmsend0, iniIrc.cmd.user0, iniIrc.cmd.user0, iniIrc.cmd.kick0, iniIrc.cmd.kick0, iniIrc.cmd.ban0, iniIrc.cmd.ban0, iniIrc.cmd.uban0, iniIrc.cmd.uban0, iniIrc.cmd.blist0, iniIrc.cmd.blist0, iniIrc.cmd.send1, iniIrc.cmd.pos1, iniIrc.cmd.pos1, iniIrc.cmd.send2, iniIrc.cmd.pos2, iniIrc.cmd.pos2), "Изменить", "Выйти", 2)
        end 
		
		if listMain == 5 then
          connected = true
        end
		
        if listMain == 6 then
		if iniIrc.config.AutoConnect == false then
		iniIrc.config.AutoConnect = not iniIrc.config.AutoConnect
		removeBlip(pool[1])
		removeBlip(pool[2])
          sampAddChatMessage(tag..clr2.."Переподключение...", -1)
          thisScript():reload()
		  else
		  removeBlip(pool[1])
		  removeBlip(pool[2])
          sampAddChatMessage(tag..clr2.."Переподключение...", -1)
          thisScript():reload()
		  end
        end
		
		if listMain == 6 then
		if iniIrc.config.AutoConnect == true then
		iniIrc.config.AutoConnect = not iniIrc.config.AutoConnect
		removeBlip(pool[1])
		removeBlip(pool[2])
          sampAddChatMessage(tag..clr2.."Отключение...", -1)
          thisScript():reload()
		  else
		  removeBlip(pool[1])
		  removeBlip(pool[2])
          sampAddChatMessage(tag..clr2.."Отключение...", -1)
		  thisScript():reload()
		  end
        end
	
        if listMain == 7 then
        iniIrc.config.AutoConnect = not iniIrc.config.AutoConnect
        sampAddChatMessage(""..tag..clr2.."АвтоПодключение: "..GetState(iniIrc.config.AutoConnect), -1)
        end
		
        if listMain == 8 then
          sampShowDialog(1292, ""..clr1.."Звук сообщений", ""..clr2.."Введите ID звука GTA, примеры: "..clr1.."1133, 1058, 1053, 1052, 1054", "Ok", "Отмена", 1)
        end		
	end
      inicfg.save(iniIrc, iniIrcFile)
end
--=========================================== СМЕНА ЗВУКА ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1292)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.config.MessageSound = stringInput
		inicfg.save(iniIrc, iniIrcFile)
        sampAddChatMessage(""..tag..clr2.."Новый звук сообщения: "..clr1..iniIrc.config.MessageSound, -1)
      else sampAddChatMessage(""..tag..clr2.."Вы отменили смену звука", -1)
      end
    end
--=========================================== PASS0 ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1991)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.config.Pass0 = stringInput
		inicfg.save(iniIrc, iniIrcFile)
		s:send("NickServ IDENTIFY %s", iniIrc.config.Pass0)
        sampAddChatMessage(""..tag..clr2.."Введен пароль: "..clr1..iniIrc.config.Pass0, -1)
      else
	  iniIrc.config.Pass0 = "-"
		inicfg.save(iniIrc, iniIrcFile)
      end
    end
--=========================================== Позывное ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1845)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.config.Poziv = stringInput
		inicfg.save(iniIrc, iniIrcFile)
        sampAddChatMessage(""..tag..clr2.."Ваше позывное: "..clr1..iniIrc.config.Poziv, -1)
      else
	  iniIrc.config.Poziv = "-"
		inicfg.save(iniIrc, iniIrcFile)
      end
    end
--=========================================== КАНАЛ1===========================================--	
    local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1291)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.config.Channel1 = stringInput
        inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили Канал1 на: "..clr1..iniIrc.config.Channel1, -1)    
		sampShowDialog(12911, ""..clr1.."Канал1", ""..clr2.."Введите ключ Канала (+k). Или нажмите 'Пропустить' если ключ на канале не установлен.", "Ok", "Пропустить", 1)	                  -- смена канала
      else sampAddChatMessage(""..tag..clr2.."Вы отменили вход на канал", -1)
	  iniIrc.config.Channel1 = "-"
	  inicfg.save(iniIrc, iniIrcFile)
      end
    end
	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(12911)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.config.Key1 = stringInput
        inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы ввели ключ Канала: "..clr1..iniIrc.config.Key1, -1)    
		wait(50)
		s:join(iniIrc.config.Channel1, iniIrc.config.Key1)   
		inicfg.save(iniIrc, iniIrcFile)
		Channel11 = string.format('%spos',iniIrc.config.Channel1)
		--s:join(Channel11, iniIrc.config.Key1)		
      else
		iniIrc.config.Key1 = "-"
		inicfg.save(iniIrc, iniIrcFile)		
		s:join(iniIrc.config.Channel1, iniIrc.config.Key1)
		inicfg.save(iniIrc, iniIrcFile)
		Channel11 = string.format('%spos',iniIrc.config.Channel1)
		--s:join(Channel11, iniIrc.config.Key1)
      end
    end
--=========================================== КАНАЛ2===========================================--	
    local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1290)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.config.Channel2 = stringInput
        inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили Канал2 на: "..clr1..iniIrc.config.Channel2, -1)    
		sampShowDialog(12900, ""..clr1.."Канал2", ""..clr2.."Введите ключ Канала (+k). Или нажмите 'Пропустить' если ключ на канале не установлен.", "Ok", "Пропустить", 1)	                  -- смена канала
      else sampAddChatMessage(""..tag..clr2.."Вы отменили вход на канал", -1)
	  iniIrc.config.Channel2 = "-"
	  inicfg.save(iniIrc, iniIrcFile)
      end
    end
	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(12900)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.config.Key2 = stringInput
        inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы ввели ключ Канала: "..clr1..iniIrc.config.Key2, -1)    
		wait(50)
		s:join(iniIrc.config.Channel2, iniIrc.config.Key2)   
		inicfg.save(iniIrc, iniIrcFile)
		Channel22 = string.format('%spos',iniIrc.config.Channel2)
		--s:join(Channel22, iniIrc.config.Key2)		
      else
		iniIrc.config.Key2 = "-"
		inicfg.save(iniIrc, iniIrcFile)		
		s:join(iniIrc.config.Channel2, iniIrc.config.Key2)
		inicfg.save(iniIrc, iniIrcFile)
		Channel22 = string.format('%spos',iniIrc.config.Channel2)
		--s:join(Channel22, iniIrc.config.Key2)
      end
    end
--=========================================== СМЕНА КОМАНД ===========================================--
	--=========================================== MENU0 ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1201)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.cmd.menu0 = stringInput
		inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили команду на: "..clr1.."/" ..iniIrc.cmd.menu0.." "..clr2.."Перезапустите скрипт чтобы изменения вступили в силу!", -1) 
      else sampAddChatMessage(""..tag..clr2.."Смена команды отменена", -1)
      end
    end
	--=========================================== PMSEND0 ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1202)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.cmd.pmsend0 = stringInput
		inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили команду на: "..clr1.."/" ..iniIrc.cmd.pmsend0.." "..clr2.."Перезапустите скрипт чтобы изменения вступили в силу!", -1) 
      else sampAddChatMessage(""..tag..clr2.."Смена команды отменена", -1)
      end
    end
--=========================================== USER0 ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1203)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.cmd.user0 = stringInput
		inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили команду на: "..clr1.."/" ..iniIrc.cmd.user0.." "..clr2.."Перезапустите скрипт чтобы изменения вступили в силу!", -1) 
      else sampAddChatMessage(""..tag..clr2.."Смена команды отменена", -1)
      end
    end
--=========================================== KICK0 ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1204)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.cmd.kick0 = stringInput
		inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили команду на: "..clr1.."/" ..iniIrc.cmd.kick0.." "..clr2.."Перезапустите скрипт чтобы изменения вступили в силу!", -1) 
      else sampAddChatMessage(""..tag..clr2.."Смена команды отменена", -1)
      end
    end
--=========================================== BAN0 ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1205)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.cmd.ban0 = stringInput
		inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили команду на: "..clr1.."/" ..iniIrc.cmd.ban0.." "..clr2.."Перезапустите скрипт чтобы изменения вступили в силу!", -1) 
      else sampAddChatMessage(""..tag..clr2.."Смена команды отменена", -1)
      end
    end
--=========================================== UBAN0 ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1206)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.cmd.uban0 = stringInput
		inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили команду на: "..clr1.."/" ..iniIrc.cmd.uban0.." "..clr2.."Перезапустите скрипт чтобы изменения вступили в силу!", -1) 
      else sampAddChatMessage(""..tag..clr2.."Смена команды отменена", -1)
      end
    end
--=========================================== BLIST0 ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1207)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.cmd.blist0 = stringInput
		inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили команду на: "..clr1.."/" ..iniIrc.cmd.blist0.." "..clr2.."Перезапустите скрипт чтобы изменения вступили в силу!", -1) 
      else sampAddChatMessage(""..tag..clr2.."Смена команды отменена", -1)
      end
    end
--=========================================== SEND1 ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1208)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.cmd.send1 = stringInput
		inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили команду на: "..clr1.."/" ..iniIrc.cmd.send1.." "..clr2.."Перезапустите скрипт чтобы изменения вступили в силу!", -1) 
      else sampAddChatMessage(""..tag..clr2.."Смена команды отменена", -1)
      end
    end
--=========================================== POS1 ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1209)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.cmd.pos1 = stringInput
		inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили команду на: "..clr1.."/" ..iniIrc.cmd.pos1.." "..clr2.."Перезапустите скрипт чтобы изменения вступили в силу!", -1) 
      else sampAddChatMessage(""..tag..clr2.."Смена команды отменена", -1)
      end
    end
--=========================================== SEND2 ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1210)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.cmd.send2 = stringInput
		inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили команду на: "..clr1.."/" ..iniIrc.cmd.send2.." "..clr2.."Перезапустите скрипт чтобы изменения вступили в силу!", -1) 
      else sampAddChatMessage(""..tag..clr2.."Смена команды отменена", -1)
      end
    end
--=========================================== POS2 ===========================================--	
	local resultInput, buttonInput, listInput, stringInput = sampHasDialogRespond(1211)
    if resultInput == true then
      if buttonInput == 1 then
        iniIrc.cmd.pos2 = stringInput
		inicfg.save(iniIrc, iniIrcFile)
		sampAddChatMessage(""..tag..clr2.."Вы сменили команду на: "..clr1.."/" ..iniIrc.cmd.pos2.." "..clr2.."Перезапустите скрипт чтобы изменения вступили в силу!", -1) 
      else sampAddChatMessage(""..tag..clr2.."Смена команды отменена", -1)
      end
    end
--====================================================================================	
	local resultMain, buttonMain, listMain = sampHasDialogRespond(1541) -- параметры команд
	local smcmd1 = ""..clr1.."Смена команды"
	local smcmd2 = ''..clr2..'Введите новую команду. (Без " '..clr1..'/ '..clr2..'")'
    if resultMain == true then
      if buttonMain == 1 then
        if listMain == 0 then
		sampShowDialog(1201, smcmd1, smcmd2, "Ok", "Отмена", 1)
		end
		if listMain == 1 then
		sampShowDialog(1202, smcmd1, smcmd2, "Ok", "Отмена", 1)
		end
		if listMain == 2 then
		sampShowDialog(1203, smcmd1, smcmd2, "Ok", "Отмена", 1)
		end
		if listMain == 3 then
		sampShowDialog(1204, smcmd1, smcmd2, "Ok", "Отмена", 1)
		end
		if listMain == 4 then
		sampShowDialog(1205, smcmd1, smcmd2, "Ok", "Отмена", 1)
		end
		if listMain == 5 then
		sampShowDialog(1206, smcmd1, smcmd2, "Ok", "Отмена", 1)
		end
		if listMain == 6 then
		sampShowDialog(1207, smcmd1, smcmd2, "Ok", "Отмена", 1)
		end
		if listMain == 8 then
		sampShowDialog(1208, smcmd1, smcmd2, "Ok", "Отмена", 1)
		end
		if listMain == 9 then
		sampShowDialog(1209, smcmd1, smcmd2, "Ok", "Отмена", 1)
		end
		if listMain == 11 then
		sampShowDialog(1210, smcmd1, smcmd2, "Ok", "Отмена", 1)
		end
		if listMain == 12 then
		sampShowDialog(1211, smcmd1, smcmd2, "Ok", "Отмена", 1)
		end
		 inicfg.save(iniIrc, iniIrcFile)
--====================================================================================	
			end
		end
	end
end  -- конец меню

function ircraw(param)
      sampAddChatMessage("{ffff00}[RAW SEND]: "..param, -1)
      sendstr = AnsiToUtf8(param)
      s:send("%s", sendstr)
    end
	
function dcrr()
	DebugMode = not DebugMode
        sampAddChatMessage(""..tag..clr2.."Сырые строки: "..GetState(DebugMode), -1)
	  end

	-- if string.find(message, Utf8ToAnsi("15You in interior! | 04Off")) or string.find(message, Utf8ToAnsi("15Coordination 04Off")) then
function removeBlipf()
  while true do wait(0)

    if pool[1] ~= nil then
      wait(5000)
      removeBlip(pool[1])
    end
	
	if pool[2] ~= nil then
      wait(5000)
      removeBlip(pool[2])
    end

  end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function spnick()	
while not sampIsLocalPlayerSpawned() do wait(1) end
	local id = select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))
	local Nick2 = sampGetPlayerNickname(id)
	s.nick = string.format("%s1%s",Nick2, id)
	iniIrc.config.Nick1 = s.nick
		inicfg.save(iniIrc, iniIrcFile)
		id1 = id
		Nick22 = Nick2
		wait(3000)
	sendstr = AnsiToUtf8(string.format("nick %s", iniIrc.config.Nick1))
	s:send(sendstr)
end
   --------------------------------------UPDATE-----------------------------------------------
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